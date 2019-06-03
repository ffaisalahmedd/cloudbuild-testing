# Builder Image - builds the code
# ===============================================================
FROM swift:4.1 as builder
RUN apt-get -qq update && rm -r /var/lib/apt/lists/*
WORKDIR /app/
COPY . .
# 1) copy Swift libraries
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so /build/lib
# 2) build project - debug mode
# RUN swift build && mv `swift build --show-bin-path` /build/bin
# 2) build project - production
RUN swift build --verbose -c release && mv `swift build -c release --show-bin-path` /build/bin

# Production Image
# ===============================================================
FROM ubuntu:16.04
RUN apt-get -qq update && apt-get install -y \
libicu55 libxml2 libbsd0 libcurl3 libatomic1 \
&& rm -r /var/lib/apt/lists/*
WORKDIR /app/
COPY --from=builder /build/bin .
COPY --from=builder /build/lib/* /usr/lib/
EXPOSE 8888
CMD ["./Run", "serve", "--hostname", "0.0.0.0", "--port", "8888"]
