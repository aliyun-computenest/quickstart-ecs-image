all:
	pip install computenest-cli
	computenest-cli generate --file_path=config.yaml.j2  --output_path=config.yaml --parameter_path=templates/parameters.yaml
	computenest-cli generate --file_path=common/templates/ecs-deploy.yaml.j2  --output_path=templates/template.yaml --parameter_path=templates/parameters.yaml
