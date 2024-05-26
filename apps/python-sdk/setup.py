from pathlib import Path

from setuptools import find_packages, setup

this_directory = Path(__file__).parent
long_description_content = (this_directory / "README.md").read_text()

setup(
    name="firecrawl-py",
    version="0.0.9",
    url="https://github.com/mendableai/firecrawl",
    author="Mendable.ai",
    author_email="nick@mendable.ai",
    description="Python SDK for Firecrawl API",
    long_description=long_description_content,
    long_description_content_type="text/markdown",
    packages=find_packages(),
    install_requires=[
        "requests",
    ],
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Environment :: Web Environment",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Operating System :: OS Independent",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Topic :: Internet",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: Indexing/Search",
        "Topic :: Software Development",
        "Topic :: Software Development :: Libraries",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: Text Processing",
        "Topic :: Text Processing :: Indexing",
    ],
)
