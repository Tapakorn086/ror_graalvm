# Base image GraalVM with native-image and Java 17
# docker build -t test-graalVM
# docker run -p 3000:3000 test-graalVM

FROM ghcr.io/graalvm/native-image:ol8-java17-22.3.3

# Set environment variables
ENV LANG=C.UTF-8 \
    RUBY_VERSION=3.2.2 \
    BUNDLER_VERSION=2.3.26

# ติดตั้งเครื่องมือพื้นฐาน
RUN microdnf install -y gcc-c++ make libpq-devel nodejs unzip zip curl git cmake xz tar \
    openssl-devel zlib-devel readline-devel glibc-langpack-en

# ติดตั้ง libyaml จาก source
RUN curl -L https://github.com/yaml/libyaml/archive/refs/tags/0.2.5.tar.gz | tar xz \
    && cd libyaml-0.2.5 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && ldconfig

# Install rbenv and ruby-build to manage Ruby versions
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
    && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
    && ~/.rbenv/bin/rbenv install $RUBY_VERSION \
    && ~/.rbenv/bin/rbenv global $RUBY_VERSION \
    && ~/.rbenv/bin/rbenv rehash

# Add rbenv to PATH
ENV PATH="/root/.rbenv/shims:/root/.rbenv/bin:$PATH"

# Install bundler for managing gems
RUN gem install bundler -v $BUNDLER_VERSION

RUN eval "$(rbenv init -)" \
    && rbenv install truffleruby-24.0.2 \
    && rbenv global truffleruby-24.0.2 \
    && gem install rails

# ตรวจสอบการติดตั้ง Ruby
RUN eval "$(rbenv init -)" \
    && ruby -v \
    && rails -v

# Create app directory
WORKDIR /app

# Install application dependencies (Rails)
COPY Gemfile* ./
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose the Rails server port
EXPOSE 3000

# Command to start the Rails server
ENTRYPOINT ["bundle", "exec", "rails", "server"]
CMD ["-b", "0.0.0.0"]

