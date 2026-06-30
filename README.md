# DSW Deployment Example

## :exclamation: Important

If you use or plan to use DSW, please let us know via [info@ds-wizard.org](mailto:info@ds-wizard.org) to:

- Join our [**Discord** server](https://discord.gg/MW3H9tdMcT), where you can be notified about important updates and releases + we can discuss your issues and ideas.
- Provide us feedback (what is good and bad, [feature requests](https://ideas.ds-wizard.org/), etc.)

This example is intended for **local setup and testing**. For production use there are many more things to do such as authentication, controlling exposed ports (e.g. do not expose ports of `postgres` and `garage`), data backups, or using proxy (with HTTPS and WebSocket enabled). As it is highly dependent on your use case, consult production deployment with your sysadmin or [contact us](https://ds-wizard.org/contact).

## Overview

This is an example deployment of the [Data Stewardship Wizard](https://ds-wizard.org) using [Docker Compose](https://docs.docker.com/compose/) and [Garage](https://garagehq.deuxfleurs.fr/) as the S3-compatible object storage.

It is intentionally set up as a **single-node local POC**:

- Garage runs in Docker on host ports `9000` (S3 API) and `9003` (Admin API)
- Garage UI runs on `127.0.0.1:8081`
- DSW points to `http://host.docker.internal:9000` so presigned URLs are reachable from the browser
- `create-bucket.sh` performs the one-time Garage bootstrap for this example

For information on how to use Data Stewardship Wizard, visit our [guide](https://guide.ds-wizard.org).

## Required Steps

These are the only steps needed to run the local example.

1. Create the local environment file:

   ```bash
   cp example.env .env
   ```

2. The tracked `config/application.yml` already contains demo application values for this example.

3. Start the stack:

   ```bash
   docker compose up -d
   ```

4. Bootstrap Garage:

   ```bash
   ./create-bucket.sh
   ```

5. Open DSW:

   [http://localhost:8080/wizard](http://localhost:8080/wizard/)

6. Log in with:

   - Email: `albert.einstein@example.com`
   - Password: `password`

## Notes

- Garage UI is available on [http://localhost:8081](http://localhost:8081) with username `admin` and password `admin`
- For local plugin testing, the plugin URL can point to `http://localhost:9004/plugins/<plugin-uuid>/<version>/`
- This repository is a local example only; if you self-host Garage publicly, place it behind HTTPS reverse proxy or another equivalent security layer

## Important Notes

* Use `docker compose pull` to get newest image (hotfixes) before starting
* **Do not expose** PostgreSQL or raw Garage ports directly to the internet in a public deployment
* If you self-host Garage publicly, place it behind an HTTPS reverse proxy or another equivalent security layer and protect admin access
* When you want to use DSW publicly, **set up HTTPS proxy** (e.g. Nginx) with a certificate for your domain and change default accounts
* Set up volume mounted to PostgreSQL and Garage containers for persistent data
* Garage needs a one-time bootstrap after the stack starts. `create-bucket.sh` assigns the single-node layout, creates the bucket, imports the configured S3 key, and grants bucket permissions
* DSW uses `http://host.docker.internal:9000` as the S3 endpoint so both the DSW containers and the browser can reach the same local Garage endpoint
* Garage UI is configured with local basic auth defaults for this POC; change them before sharing the setup
* Always use **strong passwords** and never use default values, **change the demo secrets** in `config/application.yml` and `.env` before using this anywhere except local testing

## Security Audit

This repository is used to regularly check vulnerabilities in the latest release of Docker images. [Grype](https://github.com/anchore/grype) tool is used (see [security-audit.yml](.github/workflows/security-audit.yml) file and related GitHub Actions runs). Once a vulnerability is detected, we are notified and start working on a new hotfix version. You should **always use the latest version** you can find used in this repository.
