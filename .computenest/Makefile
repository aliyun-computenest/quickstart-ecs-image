all:
	pip install computenest-cli==1.2.8.1
	computenest-cli generate --file_path=code_generation/config.yaml.j2 --parameter_path=code_generation/variables.yaml --output_path=config.yaml
	computenest-cli generate --file_path=code_generation/ros_templates/template.yaml.j2 --parameter_path=code_generation/variables.yaml --output_path=ros_templates/template.yaml
test:
	pip install computenest-cli==1.2.8.1
	computenest-cli generate --file_path=code_generation/config.yaml.j2  --output_path=config.yaml --parameters='{"EcsImageArtifactId":"artifact-xxx","EcsImageArtifactVersion":"draft","Parameters":[{"Name":"AdminPassword","NoEcho":true,"Type":"String","Label":"管理员密码","AssociationProperty":"ALIYUN::ECS::Instance::Password"}],"CommandTimeout":300,"Command":"#!/bin/bash\necho $${AdminPassword}\n","InstanceTypes":["ecs.c6.large","ecs.c6.xlarge","ecs.c6.2xlarge"],"Ports":[8080],"Outputs":[{"Label":"Endpoint","Expression":"https://$${Address}:8080"}]}'
	computenest-cli generate --file_path=code_generation/ros_templates/template.yaml.j2  --output_path=ros_templates/template.yaml --parameters='{"EcsImageArtifactId":"artifact-xxx","EcsImageArtifactVersion":"draft","Parameters":[{"Name":"AdminPassword","NoEcho":true,"Type":"String","Label":"管理员密码","AssociationProperty":"ALIYUN::ECS::Instance::Password"}],"CommandTimeout":300,"Command":"#!/bin/bash\necho $${AdminPassword}\n","InstanceTypes":["ecs.c6.large","ecs.c6.xlarge","ecs.c6.2xlarge"],"Ports":[8080],"Outputs":[{"Label":"Endpoint","Expression":"https://$${Address}:8080"}]}'
