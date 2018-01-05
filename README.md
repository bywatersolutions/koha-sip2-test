# koha-sip2-test

## Koha SIP2 Tester

This is repository for a Docker image that can be used to test all the users set up in a Koha SIP2 config file to ensure they are working.

### Usage

The Docker image can be run directly like so:
```bash
docker run --mount type=bind,source=/path/to/instance.yml,target=/vars.yml kylemhall/koha-sip2-test test_sip.pl /vars.yml"
```

If that is too much to type, this repo contains a handy shell script to cut down on typing:

```bash
test_sip instance_name
```
