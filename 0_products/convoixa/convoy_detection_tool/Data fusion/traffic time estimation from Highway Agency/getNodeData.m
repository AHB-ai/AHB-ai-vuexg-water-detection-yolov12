function [information, subNode] = getNodeData(Node, NodeName, type)
   information = '';
   if Node.hasChildNodes
       subNodes = Node.getChildNodes;
       for i=1:subNodes.getLength
           childNode = subNodes.item(i-1);
           name = regexprep(char(childNode.getNodeName),'[-:.]','_');
           if (~strcmp(name,'#text') && ~strcmp(name,'#comment'))
               if strcmp(name, NodeName)
                   if strcmp(type, 'attributes')
                       information = char(childNode.getAttributes.item(0).getValue);
                   end
                   if strcmp(type, 'text')
                       information = char(childNode.getTextContent);
                   end                   
                   subNode = childNode;
               end
           end
       end
   end
end
