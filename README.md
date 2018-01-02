# koha-sip2-test

## Koha SIP2 Tester

This is repository for a Docker image that can be used to test all the users set up in a Koha SIP2 config file to ensure they are working.

### Usage

This tester needs to things:
* A SIPConfig.xml file ( from Koha )
* A server address for the SIP2 server

The Docker image can be run directly like so:
```bash
docker run --mount type=bind,source=/PATH/TO/SIPconfig.xml,target=/SIPconfig.xml koha-sip2-cli-docker test_sip.pl /SIPconfig.xml sip2.server.address
```

If that is too much to type, this repo contains a handy shell script to cut down on typing:

```bash
test_sip /PATH/TO/SIPconfig.xml sip2.server.address
```
