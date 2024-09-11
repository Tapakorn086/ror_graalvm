
# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t my-app .
# docker run -d -p 80:80 -p 443:443 --name my-app -e RAILS_MASTER_KEY=<value from config/master.key> my-app

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version

# ใช้ GraalVM base image
FROM ghcr.io/graalvm/graalvm-community:22

# ติดตั้งเครื่องมือพื้นฐาน
RUN microdnf install -y gcc-c++ make libpq-devel nodejs unzip zip curl git cmake xz tar

# ติดตั้ง libyaml จาก source
RUN curl -L https://github.com/yaml/libyaml/archive/refs/tags/0.2.5.tar.gz | tar xz \
    && cd libyaml-0.2.5 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && ldconfig

# ติดตั้ง rbenv และ ruby-build
RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash

# ตั้งค่า PATH และติดตั้ง Ruby
ENV PATH="/root/.rbenv/bin:${PATH}"
RUN eval "$(rbenv init -)" \
    && rbenv install 3.1.2 \
    && rbenv global 3.1.2 \
    && gem install bundler rails

# ติดตั้ง TruffleRuby และ Rails
RUN eval "$(rbenv init -)" \
    && rbenv install truffleruby-24.0.2 \
    && rbenv global truffleruby-24.0.2 \
    && gem install rails

# ตรวจสอบการติดตั้ง Ruby
RUN eval "$(rbenv init -)" \
    && ruby -v \
    && rails -v

# สร้าง directory สำหรับแอปพลิเคชัน
WORKDIR /app

# คัดลอกไฟล์แอปพลิเคชัน
COPY . .

# ติดตั้ง dependencies ของ Ruby
RUN eval "$(rbenv init -)" \
    && bundle install

# คอมไพล์โปรเจกต์
RUN eval "$(rbenv init -)" \
    && bundle exec rake assets:precompile

# ตั้งค่าคำสั่งเริ่มต้น
CMD ["bash", "-c", "export PATH=\"$HOME/.rbenv/bin:$PATH\" && eval \"$(rbenv init -)\" && rails server -b 0.0.0.0"]
