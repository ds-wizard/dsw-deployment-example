# DSW Deployment Example

:exclamation: This example is intended for **local setup and testing**. For production use do not forget to set authentication or control exposed ports (e.g. do not expose ports of `mongo` and `rabbitmq`).

This is an example deployment of the [Data Stewardship Wizard](https://ds-wizard.org) using [docker-compose](https://docs.docker.com/compose/). You can clone the repository and run it with:

```
$ docker-compose up -d
```

Then visit [localhost:8080](http://localhost:8080) and login as `albert.einstein@example.com` with password `password`.

We recommend reading the [Installation](https://docs.ds-wizard.org/en/latest/admin/installation.html) and [Configuration](https://docs.ds-wizard.org/en/latest/admin/configuration.html) chapters in the documentation. After starting the DSW, you can log in using [Default User Accounts](https://docs.ds-wizard.org/en/latest/admin/installation.html#default-users). The fresh installation does not contain any knowledge model, you can read about how to get the [Initial Knowledge Model](https://docs.ds-wizard.org/en/latest/admin/installation.html#initial-knowledge-model).

## Important notes

* Do not expose RabbitMQ and MongoDB to the internet
* When you want to use DSW publicly, set up proxy with a certificate for your domain and change default accounts
* Set up backups for folder mounted to MongoDB container
