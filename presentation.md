OAuth2 and Mojolicious

[Lee Johnson](http://leejo.github.io)

Swiss Perl Workshop August 2015

---
## [OAuth 2.0](https://tools.ietf.org/html/rfc6749)

---
Not really going to talk about OAuth 2.0 fundamentals here

Such as [how](https://tools.ietf.org/html/rfc6749#section-4.1) it works, [why](http://oauth2.thephpleague.com/authorization-server/which-grant/) you would use it, or its [problems](http://hueniverse.com/2012/07/26/oauth-2-0-and-the-road-to-hell/).

However, a recap...

---
"Authorization Code Grant"

                     +----------+          Client Identifier      +----------+
    +----------+     |         -+----(A)-- & Redirection URI ---->|          |
    | Resource |     |  User-   |                                 |   Auth   |
    |   Owner  <-(B)--  Agent  -+----(B)-- User authenticates --->|  Server  |
    |          |     |          |                                 |          |
    +----------+     |         -+----(C)-- Authorization Code ---<|          |
                     +-|----|---+                                 +----------+
                       |    |                                        ^    v
                      (A)  (C)                                       |    |
                       |    |                                        |    |
                       ^    v                                        |    |
                     +---------+                                     |    |
                     |         |>---(D)-- Authorization Code --------'    |
                     |  Client |          & Redirection URI               |
                     |         |                                          |
                     |         |<---(E)----- Access Token ----------------'
                     +---------+       (w/ Optional Refresh Token)

---
[Simple!](https://www.youtube.com/watch?v=xeGxGnSkSdQ)

---
## An example!

---
## Client Implementation

[Mojolicious::Plugin::OAuth2](https://metacpan.org/release/Mojolicious-Plugin-OAuth2)

---
## Server Implementation

[Mojolicious::Plugin::OAuth2::Server](https://metacpan.org/release/Mojolicious-Plugin-OAuth2-Server)

---
* simple example
* but it's not that simple...
* great for testing / emulation

---
* in reality

---
## An example using those plugins

* client plugin speaking to the server plugin
* command line

---
There are other modules for doing this on CPAN:

* [OAuth::Lite2](https://metacpan.org/release/OAuth-Lite2) - Client / Server
* [Net::OAuth2](https://metacpan.org/release/Net-OAuth2) - Client / Server
* [Net::OAuth2::Scheme](https://metacpan.org/release/CatalystX-OAuth2) - Server
* [CatalystX::OAuth2](https://metacpan.org/release/CatalystX-OAuth2) - Client
* [CatalystX::OAuth2::Provider](https://metacpan.org/release/CatalystX-OAuth2-Provider) - Server
* [LWP::Authen::OAuth2](https://metacpan.org/pod/LWP::Authen::OAuth2) - Client


---
## Questions?
