# URL Shortner

Web App built using Vapor that shortens URL.

## Getting Started

### Docker

Easy way to get started is by running `docker-compose up`. Make sure you have the latest version of docker installed. It may take some time to download all of the images and build the project but you will have a running application in a container.

### Xcode

To run in Xcode run `vapor xcode -y`. This will generate the Xcode project and open it. Then you can run the application from Xcode. You need to make sure you have `postgres` database running locally and you need to add the `postgresql.json` config to your `Config` folder or under `Config/secrets` folder:

```json
{
    "hostname": "0.0.0.0",
    "user": "postgres",
    "password": "",
    "database": "urls",
    "port": 5432
}
```

## Deployment

To deploy the application just run `vapor heroku init` and answer the prompts on the command line. Add postgres to your heroku account `heroku addons:create heroku-postgresql:hobby-dev` and then to deploy just push to `heroku` remote using this command `git push heroku master`
