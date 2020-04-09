# nginx-fpm-custom
Custom docker image for nginx and PHP 7.2 fpm using supervisor

After exploring many different options out there for running a lightweight nginx based PHP docker container, this is what I have come up with.

It provides several extensions that I need for my client's projects. This includes including mailparse, memcached, and redis.  Composer is installed by default in the image.

