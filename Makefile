all:
	pip install computenest-cli
	computenest-cli generate --file_path=config.yaml.j2  --output_path=config.yaml --parameter_path=templates/parameters.yaml
	computenest-cli generate --file_path=common/templates/ecs-deploy.yaml.j2  --output_path=templates/template.yaml --parameter_path=templates/parameters.yaml
test:
	pip install computenest-cli
	computenest-cli generate --file_path=config.yaml.j2  --output_path=config.yaml --parameters='{"EcsImageArtifactId":"artifact-xxx","EcsImageArtifactVersion":"draft","Parameters":[{"Name":"AdminPassword","NoEcho":true,"Type":"String","Label":"管理员密码","AssociationProperty":"ALIYUN::ECS::Instance::Password"}],"Command":"#!/bin/bash\necho ${AdminPassword}\n","InstanceTypes":["ecs.c6.large","ecs.c6.xlarge","ecs.c6.2xlarge"],"Ports":[8080],"Outputs":[{"DisplayName":"Endpoint","Expression":"https://${Address}:8080"}]}'