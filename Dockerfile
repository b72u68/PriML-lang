FROM ubuntu:20.04

# Install dependencies and mlton-20130715
RUN apt-get update -y
RUN apt-get install -y build-essential libgmp-dev mlton mlton-tools

# Copy the current working directory (PriML-lang) to a location within the container
COPY . /PriML-lang
WORKDIR /PriML-lang

# Build mlton-parmem
RUN make mlton-parmem

# Build primlc
CMD ["make"]
