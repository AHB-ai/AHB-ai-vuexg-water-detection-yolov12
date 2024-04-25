import { withAuth } from "../../lib/withAuth";
import { supabase_service } from "../supabase";

const FREE_CREDITS = 100;

export async function billTeam(team_id: string, credits: number) {
  return withAuth(supaBillTeam)(team_id, credits);
}
export async function supaBillTeam(team_id: string, credits: number) {
  if (team_id === "preview") {
    return { success: true, message: "Preview team, no credits used" };
  }
  console.log(`Billing team ${team_id} for ${credits} credits`);
  //   When the API is used, you can log the credit usage in the credit_usage table:
  // team_id: The ID of the team using the API.
  // subscription_id: The ID of the team's active subscription.
  // credits_used: The number of credits consumed by the API call.
  // created_at: The timestamp of the API usage.

  // 1. get the subscription

  const { data: subscription } = await supabase_service
    .from("subscriptions")
    .select("*")
    .eq("team_id", team_id)
    .eq("status", "active")
    .single();

  if (!subscription) {
    const { data: credit_usage } = await supabase_service
      .from("credit_usage")
      .insert([
        {
          team_id,
          credits_used: credits,
          created_at: new Date(),
        },
      ])
      .select();

    return { success: true, credit_usage };
  }

  // 2. Check for available coupons
  const { data: coupons } = await supabase_service
    .from("coupons")
    .select("credits")
    .eq("team_id", team_id)
    .eq("status", "active");

  let couponValue = 0;
  if (coupons && coupons.length > 0) {
    couponValue = coupons[0].credits; // Assuming only one active coupon can be used at a time
    console.log(`Applying coupon of ${couponValue} credits`);
  }

  // Calculate final credits used after applying coupon
  const finalCreditsUsed = Math.max(0, credits - couponValue);

  // 3. Log the credit usage
  const { data: credit_usage } = await supabase_service
    .from("credit_usage")
    .insert([
      {
        team_id,
        subscription_id: subscription ? subscription.id : null,
        credits_used: finalCreditsUsed,
        created_at: new Date(),
      },
    ])
    .select();

  return { success: true, credit_usage };
}

export async function checkTeamCredits(team_id: string, credits: number) {
  return withAuth(supaCheckTeamCredits)(team_id, credits);
}
// if team has enough credits for the operation, return true, else return false
export async function supaCheckTeamCredits(team_id: string, credits: number) {
  if (team_id === "preview") {
    return { success: true, message: "Preview team, no credits used" };
  }

  // Retrieve the team's active subscription
  const { data: subscription, error: subscriptionError } = await supabase_service
    .from("subscriptions")
    .select("id, price_id, current_period_start, current_period_end")
    .eq("team_id", team_id)
    .eq("status", "active")
    .single();

  if (subscriptionError || !subscription) {
    return { success: false, message: "No active subscription found" };
  }

  // Check for available coupons
  const { data: coupons } = await supabase_service
    .from("coupons")
    .select("credits")
    .eq("team_id", team_id)
    .eq("status", "active");

  let couponValue = 0;
  if (coupons && coupons.length > 0) {
    couponValue = coupons[0].credits;
  }

  // Calculate the total credits used by the team within the current billing period
  const { data: creditUsages, error: creditUsageError } = await supabase_service
    .from("credit_usage")
    .select("credits_used")
    .eq("subscription_id", subscription.id)
    .gte("created_at", subscription.current_period_start)
    .lte("created_at", subscription.current_period_end);

  if (creditUsageError) {
    throw new Error(`Failed to retrieve credit usage for subscription_id: ${subscription.id}`);
  }

  const totalCreditsUsed = creditUsages.reduce((acc, usage) => acc + usage.credits_used, 0);

  // Adjust total credits used by subtracting coupon value
  const adjustedCreditsUsed = Math.max(0, totalCreditsUsed - couponValue);

  // Get the price details
  const { data: price, error: priceError } = await supabase_service
    .from("prices")
    .select("credits")
    .eq("id", subscription.price_id)
    .single();

  if (priceError) {
    throw new Error(`Failed to retrieve price for price_id: ${subscription.price_id}`);
  }

  // Compare the adjusted total credits used with the credits allowed by the plan
  if (adjustedCreditsUsed + credits > price.credits) {
    return { success: false, message: "Insufficient credits, please upgrade!" };
  }

  return { success: true, message: "Sufficient credits available" };
}

// Count the total credits used by a team within the current billing period and return the remaining credits.
export async function countCreditsAndRemainingForCurrentBillingPeriod(
  team_id: string
) {
  // 1. Retrieve the team's active subscription based on the team_id.
  const { data: subscription, error: subscriptionError } =
    await supabase_service
      .from("subscriptions")
      .select("id, price_id, current_period_start, current_period_end")
      .eq("team_id", team_id)
      .single();

  if (subscriptionError || !subscription) {
    // Check for available coupons even if there's no subscription
    const { data: coupons } = await supabase_service
      .from("coupons")
      .select("value")
      .eq("team_id", team_id)
      .eq("status", "active");

    let couponValue = 0;
    if (coupons && coupons.length > 0) {
      couponValue = coupons[0].value;
    }

    // Free
    const { data: creditUsages, error: creditUsageError } =
      await supabase_service
        .from("credit_usage")
        .select("credits_used")
        .is("subscription_id", null)
        .eq("team_id", team_id);

    if (creditUsageError || !creditUsages) {
      throw new Error(`Failed to retrieve credit usage for team_id: ${team_id}`);
    }

    const totalCreditsUsed = creditUsages.reduce(
      (acc, usage) => acc + usage.credits_used,
      0
    );

    // Adjust total credits used by subtracting coupon value
    const adjustedCreditsUsed = Math.max(0, totalCreditsUsed - couponValue);

    // 4. Calculate remaining credits.
    const remainingCredits = FREE_CREDITS - adjustedCreditsUsed;

    return { totalCreditsUsed: adjustedCreditsUsed, remainingCredits, totalCredits: FREE_CREDITS };
  }

  // If there is an active subscription
  const { data: coupons } = await supabase_service
  .from("coupons")
  .select("credits")
  .eq("team_id", team_id)
  .eq("status", "active");

  let couponValue = 0;
  if (coupons && coupons.length > 0) {
  couponValue = coupons[0].credits;
  }

  const { data: creditUsages, error: creditUsageError } = await supabase_service
  .from("credit_usage")
  .select("credits_used")
  .eq("subscription_id", subscription.id)
  .gte("created_at", subscription.current_period_start)
  .lte("created_at", subscription.current_period_end);

  if (creditUsageError || !creditUsages) {
  throw new Error(`Failed to retrieve credit usage for subscription_id: ${subscription.id}`);
  }

  const totalCreditsUsed = creditUsages.reduce(
  (acc, usage) => acc + usage.credits_used,
  0
  );

  // Adjust total credits used by subtracting coupon value
  const adjustedCreditsUsed = Math.max(0, totalCreditsUsed - couponValue);

  const { data: price, error: priceError } = await supabase_service
  .from("prices")
  .select("credits")
  .eq("id", subscription.price_id)
  .single();

  if (priceError || !price) {
  throw new Error(`Failed to retrieve price for price_id: ${subscription.price_id}`);
  }

  // Calculate remaining credits.
  const remainingCredits = price.credits - adjustedCreditsUsed;

  return {
  totalCreditsUsed: adjustedCreditsUsed,
  remainingCredits,
  totalCredits: price.credits
  };
  }
