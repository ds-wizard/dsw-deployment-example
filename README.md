# DSW Deployment Example

## :exclamation: Important

If you use or plan to use DSW, please let us know via [info@ds-wizard.org](mailto:info@ds-wizard.org) to:

- Join our [**Discord** server](https://discord.gg/MW3H9tdMcT), where you can be notified about importat updates and releases + we can discuss your issues and ideas.
- Provide us feedback (what is good and bad, [feature requests](https://ideas.ds-wizard.org/), etc.)

This example is intended for **local setup and testing**. For production use there are many more things to do such as authentication, controlling exposed ports (e.g. do not expose ports of `postgres` and `minio`), data backups, or using proxy (with HTTPS and WebSocket enabled). As it is highly dependent on your use case, consult production deployment with your sysadmin or [contact us](https://ds-wizard.org/contact).

## Usage

This is an example deployment of the [Data Stewardship Wizard](https://ds-wizard.org) using [docker-compose](https://docs.docker.com/compose/). You can clone the repository and run it with:

```
$ docker-compose up -d
```

Then visit [localhost:8080/wizard](http://localhost:8080/wizard/) and login as `albert.einstein@example.com` with password `password`.

For information on how to use Data Stewardship Wizard, visit our [guide](https://guide.ds-wizard.org).

## Important notes

* Use `docker compose pull` to get newest image (hotfixes) before starting
* **Do not expose** PostgreSQL and MinIO to the internet (MinIO should be exposed only via proxy)
* When you want to use DSW publicly, **set up HTTPS proxy** (e.g. Nginx) with a certificate for your domain and change default accounts
* Set up volume mounted to PostgreSQL and MinIO containers for persistent data
* You have to create S3 bucket, either using Web UI (for MinIO, you can expose and use `http://localhost:9000`) or via client: https://docs.min.io/docs/minio-client-complete-guide.html#mb, e.g. use `create-bucket.sh` script
* Always use **strong passwords** and never use default values, **change the secrets** in `config/application.yml` (32 character string in `general.secret` and RSA private key in `general.rsaPrivateKey` via `ssh-keygen -t rsa -b 4096 -m PEM -f jwtRS256.key`)

## Security Audit

This repository is used to regularly check vulnerabilities in the latest release of Docker images. [Grype](https://github.com/anchore/grype) tool is used (see [security-audit.yml](.github/workflows/security-audit.yml) file and related GitHub Actions runs). Once a vulnerability is detected, we are notified and start working on a new hotfix version. You should **always use the latest version** you can find used in this repository.
