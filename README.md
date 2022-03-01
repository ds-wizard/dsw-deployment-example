# DSW Deployment Example

:exclamation: This example is intended for **local setup and testing**. For production use there are many more things to do such as authentication, controlling exposed ports (e.g. do not expose ports of `postgres` and `minio`), data backups, or using proxy (with HTTPS and WebSocket enabled). As it is highly dependent on your use case, consult production deployment with your sysadmin or contact us for [professional services](https://ds-wizard.org/services.html).

## Usage

This is an example deployment of the [Data Stewardship Wizard](https://ds-wizard.org) using [docker-compose](https://docs.docker.com/compose/). You can clone the repository and run it with:

```
$ docker-compose up -d
```

Then visit [localhost:8080](http://localhost:8080) and login as `albert.einstein@example.com` with password `password`.

We recommend reading the [Installation](https://docs.ds-wizard.org/en/latest/admin/installation.html) and [Configuration](https://docs.ds-wizard.org/en/latest/admin/configuration.html) chapters in the documentation. After starting the DSW, you can log in using [Default User Accounts](https://docs.ds-wizard.org/en/latest/admin/installation.html#default-users). The fresh installation does not contain any knowledge model, you can read about how to get the [Initial Knowledge Model](https://docs.ds-wizard.org/en/latest/admin/installation.html#initial-knowledge-model).

For information on how to use Data Stewardship Wizard, visit our [guide](https://guide.ds-wizard.org).

## Important notes

* Do not expose PostgreSQL and Minio to the internet
* When you want to use DSW publicly, set up proxy (e.g. Nginx) with a certificate for your domain and change default accounts
* Set up volume mounted to PostgreSQL and Minio containers for persistent data
* You have to create S3 bucket, either using Web UI (for Minio, you can expose and use `http://localhost:9000`) or via client: https://docs.min.io/docs/minio-client-complete-guide.html#mb, e.g. use `create-bucket.sh` script.
