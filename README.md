# awscip

![Github Action](https://github.com/Parcothsai/awscip/actions/workflows/docker_build_multiple_arch.yml/badge.svg?event=push)
![SNYK](https://github.com/Parcothsai/awscip/actions/workflows/snyk_docker_analyse.yml/badge.svg?event=push)


## Description

awscip for aws change ip.

Create or update record to aws route53 on a single domain.

DockerHub url : https://hub.docker.com/r/luninfoparco/awscip

## Using docker-compose

```bash
git clone https://github.com/Parcothsai/awscip.git
cd  awscip
# Replace "test" with your correct information
sed -i "s/your_aws_access_key_id/test/g" docker-compose.yml
sed -i "s/your_aws_secret_access_key/test/g" docker-compose.yml
sed -i "s/your_aws_region/test/g" docker-compose.yml
sed -i "s/your_aws_zone_id/test/g" docker-compose.yml

cat > domains.list << EOF 
first.exemple.com
second.exemple.com
EOF
```

Then :
```bash
docker-compose up -d
```

## Versions

|    name      |     version      |
|:------------:|:----------------:|
|    alpine    |    3.17.3        |
|    python    |    3.10          |
|    pip       |    22.3          |
|    awscli    |    1.27          |
|              |                  |


## TODO

- :ballot_box_with_check: Add github action to build docker image and push to https://hub.docker.com/r/luninfoparco/awscip
- :x: Add the possibility for a user to have multiple domains
- :x: Add kubernetes chart for cronjob