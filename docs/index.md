# 服务模版说明文档

## 服务模板说明

本文介绍基于ECS镜像的单机ECS服务模板，本示例对应的[git地址](https://github.com/aliyun-computenest/quickstart-ecs-image)

本示例会自动地构建计算巢服务，具体的服务构建流程为
1. 服务商需要提前创建好镜像部署物，参考[官网文档](https://help.aliyun.com/zh/compute-nest/create-a-deployment-object)
2. 选择此服务模板创建计算巢服务，关联镜像部署物，定制服务入参和输出
3. 提交后自动创建服务，创建过程大约持续2分钟，当服务变成待预发布后构建成功

### 服务模板支持的配置
从此服务模板创建服务，支持服务商指定以下信息

|配置组| 配置项                          | 说明                     |
|---------|---------------------------------|------------------------|
|服务信息| 服务图标             |        |
|服务信息| 服务名称             |        |
|服务信息| 服务简介             |        |
|服务信息| 版本描述             | 初始版本的版本描述       |
|软件配置| 部署地域列表             |支持用户部署的地域列表。部署物必须分发到这些地域。不填代表支持所有地域。         |
|软件配置| ECS镜像部署物             |ECS镜像部署物的ID和版本，ECS镜像可以包含服务商软件以及运行环境         |
|软件配置| 自定义服务参数             |服务商自定义的入参，可以在命令和输出中引用         |
|软件配置| 初始化命令             | 通过初始化命令可以对软件进行初始化，也可以执行其他需要的操作        |
|软件配置| 命令超时时间             |命令执行超时后服务实例部署失败         |
|实例配置| ECS实例规格列表             |用户可选的ECS实例规格范围        |
|实例配置| 安全组开放端口             |安全组开放的的入方向端口列表        |
|输出配置| 服务输出 | 服务的输出配置，服务实例部署成功后用户可以在服务实例详情中看到输出信息 |


## 部署架构

部署架构为单机ecs部署，通过公网ip 8080端口访问
<img src="architecture.png" width="1500" height="700" align="bottom"/>

## 服务构建计费说明
通过此服务模板构建服务不产生费用

## RAM账号所需权限

本服务需要对ECS、VPC等资源进行访问和创建操作，若您使用RAM用户创建服务实例，需要在创建服务实例前，对使用的RAM用户的账号添加相应资源的权限。添加RAM权限的详细操作，请参见[为RAM用户授权](https://help.aliyun.com/document_detail/121945.html)。所需权限如下表所示。

| 权限策略名称                          | 备注                     |
|---------------------------------|------------------------|
| AliyunECSFullAccess             | 管理云服务器服务（ECS）的权限       |
| AliyunVPCFullAccess             | 管理专有网络（VPC）的权限         |
| AliyunROSFullAccess             | 管理资源编排服务（ROS）的权限       |
| AliyunComputeNestUserFullAccess | 管理计算巢服务（ComputeNest）的用户侧权限 |
| AliyunComputeNestSupplierFullAccess | 管理计算巢服务（ComputeNest）的服务商侧权限 ｜

## 服务实例计费说明

测试本服务在计算巢上的费用主要涉及：

- 所选vCPU与内存规格
- 系统盘类型及容量
- 公网带宽

计费方式包括：

- 按量付费（小时）
- 包年包月

服务支持的ECS实例规格由服务商在创建服务时配置。

预估费用在创建实例时可实时看到。


## 部署流程

### 部署参数说明
用户可见的部署参数，由服务模板中的固定参数和服务商自定义的服务参数组成。

其中，服务模板中的固定参数定义在common/templates/ecs-deploy.yaml.j2中，包括付费类型、ECS实例类型及VPC网络等参数

```
  PayType:
    Type: String
    Label:
      en: ECS Instance Charge Type
      zh-cn: 付费类型
    Default: PostPaid
    AllowedValues:
      - PostPaid
      - PrePaid
    AssociationProperty: ChargeType
    AssociationPropertyMetadata:
      LocaleKey: InstanceChargeType
  PayPeriodUnit:
    Type: String
    Label:
      en: Pay Period Unit
      zh-cn: 购买资源时长周期
    Default: Month
    AllowedValues:
      - Month
      - Year
    AssociationProperty: PayPeriodUnit
    AssociationPropertyMetadata:
      Visible:
        Condition:
          Fn::Not:
            Fn::Equals:
              - ${PayType}
              - PostPaid
  PayPeriod:
    Type: Number
    Label:
      en: Period
      zh-cn: 购买资源时长
    Default: 1
    AllowedValues:
      - 1
      - 2
      - 3
      - 4
      - 5
      - 6
      - 7
      - 8
      - 9
    AssociationProperty: PayPeriod
    AssociationPropertyMetadata:
      Visible:
        Condition:
          Fn::Not:
            Fn::Equals:
              - ${PayType}
              - PostPaid
  EcsInstanceType:
    Type: String
    Label:
      en: Instance Type
      zh-cn: 实例类型
    AssociationProperty: ALIYUN::ECS::Instance::InstanceType
    AssociationPropertyMetadata:
      InstanceChargeType: ${PayType}
    {%- if InstanceTypes %}
    AllowedValues:{% for InstanceType in InstanceTypes %}
      - {{ InstanceType }}
      {%- endfor %}
    {% endif %}
  InstancePassword:
    NoEcho: true
    Type: String
    Description:
      en: Server login password, Length 8-30, must contain three(Capital letters, lowercase letters, numbers, ()`~!@#$%^&*_-+=|{}[]:;'<>,.?/ Special symbol in)
      zh-cn: 服务器登录密码,长度8-30，必须包含三项（大写字母、小写字母、数字、 ()`~!@#$%^&*_-+=|{}[]:;'<>,.?/ 中的特殊符号）
    AllowedPattern: '^[a-zA-Z0-9-\(\)\`\~\!\@\#\$\%\^\&\*\_\-\+\=\|\{\}\[\]\:\;\<\>\,\.\?\/]*$'
    Label:
      en: Instance Password
      zh-cn: 实例密码
    ConstraintDescription:
      en: Length 8-30, must contain three(Capital letters, lowercase letters, numbers, ()`~!@#$%^&*_-+=|{}[]:;'<>,.?/ Special symbol in)
      zh-cn: 长度8-30，必须包含三项（大写字母、小写字母、数字、 ()`~!@#$%^&*_-+=|{}[]:;'<>,.?/ 中的特殊符号）
    MinLength: 8
    MaxLength: 30
    AssociationProperty: ALIYUN::ECS::Instance::Password
  ZoneId:
    Type: String
    Label:
      en: Zone ID
      zh-cn: 可用区ID
    AssociationProperty: ALIYUN::ECS::Instance::ZoneId
  VpcId:
    Type: String
    Label:
      en: VPC ID
      zh-cn: 专有网络VPC实例ID
    Description:
      en: >-
        Please search the ID starting with (vpc-xxx) from console-Virtual
        Private Cloud
      zh-cn: 现有虚拟专有网络的实例ID
    AssociationProperty: 'ALIYUN::ECS::VPC::VPCId'
  VSwitchId:
    Type: String
    Label:
      en: VSwitch ID
      zh-cn: 交换机实例ID
    Description:
      en: >-
        Instance ID of existing business network switches, console-Virtual
        Private Cloud-VSwitches under query
      zh-cn: 现有业务网络交换机的实例ID
    Default: ''
    AssociationProperty: 'ALIYUN::ECS::VSwitch::VSwitchId'
    AssociationPropertyMetadata:
      VpcId: VpcId
      ZoneId: ZoneId
```
### 部署资源说明
服务模板部署的资源定义在common/templates/ecs-deploy.yaml.j2中，包括安全组和ECS实例资源

```
  SecurityGroup:
    Type: ALIYUN::ECS::SecurityGroup
    Properties:
      SecurityGroupName:
        Ref: ALIYUN::StackName
      VpcId:
        Ref: VpcId
      SecurityGroupIngress: {%- for Port in Ports %}
        - PortRange: {{ Port }}/{{ Port }}
          Priority: 1
          SourceCidrIp: 0.0.0.0/0
          IpProtocol: tcp
          NicType: internet
      {%- endfor %}
  InstanceGroup:
    Type: ALIYUN::ECS::InstanceGroup
    Properties:
      # 付费类型
      InstanceChargeType:
        Ref: PayType
      PeriodUnit:
        Ref: PayPeriodUnit
      Period:
        Ref: PayPeriod
      VpcId:
        Ref: VpcId
      VSwitchId:
        Ref: VSwitchId
      SecurityGroupId:
        Ref: SecurityGroup
      ZoneId:
        Ref: ZoneId
      ImageId: centos_7_8_x64_20G_alibase_20211130.vhd
      Password:
        Ref: InstancePassword
      InstanceType:
        Ref: EcsInstanceType
      SystemDiskCategory: cloud_essd
      SystemDiskSize: 200
      InternetMaxBandwidthOut: 5
      IoOptimized: optimized
      MaxAmount: 1
  WaitCondition:
    Type: ALIYUN::ROS::WaitCondition
    Properties:
      Count: 1
      Handle:
        Ref: WaitConditionHandle
      Timeout: {{ CommandTimeout }}
  WaitConditionHandle:
    Type: ALIYUN::ROS::WaitConditionHandle
  InstallPackage:
    Type: ALIYUN::ECS::RunCommand
    Properties:
      InstanceIds:
        Fn::GetAtt:
          - InstanceGroup
          - InstanceIds
      Type: RunShellScript
      Sync: true
      Timeout: {{ CommandTimeout }}
      CommandContent:
        Fn::Sub:
          - |
            {{ Command | indent(width=12)}}
            # 执行成功回调WaitCondition结束waitCondition的等待
            ${CurlCli} -d "{\"Data\" : \"Success\", \"status\" : \"SUCCESS\"}"
          - CurlCli:
              Fn::GetAtt:
                - WaitConditionHandle
                - CurlCli
```

## 服务配置

[创建代运维服务完成实例运维](https://help.aliyun.com/zh/compute-nest/create-a-hosted-operations-and-maintenance-service?spm=a2c4g.11186623.0.i24#task-2167552])

[创建包含变配功能的服务](https://help.aliyun.com/zh/compute-nest/use-cases/create-a-service-that-supports-specification-changes-and-change-the-specifications-of-a-service-instance?spm=a2c4g.11186623.0.i3])

[创建包含服务升级功能的服务](https://help.aliyun.com/zh/compute-nest/upgrade-a-service-instance?spm=a2c4g.11186623.0.i17#task-2236803)

## 服务交付

[自定义服务架构图](https://help.aliyun.com/zh/compute-nest/customize-a-service-architecture?spm=a2c4g.11186623.0.0.56e736bfyUdlFm])

[服务文档上线流程](https://help.aliyun.com/zh/compute-nest/use-cases/publish-documents-to-compute-nest?spm=a2c4g.313309.0.i0])

[将服务上架云市场并上到云市场售卖](https://help.aliyun.com/zh/compute-nest/publish-a-service-to-alibaba-cloud-marketplace?spm=a2c4g.11186623.0.i7])

## 其他说明

[实例代码源地址](https://atomgit.com/flow-example/spring-boot)

[软件包package.tgz构建流程参考](https://help.aliyun.com/document_detail/153848.html)
