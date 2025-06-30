# lambda CfHighlander component
## Parameters

| Name | Use | Default | Global | Type | Allowed Values |
| ---- | --- | ------- | ------ | ---- | -------------- |
| EnvironmentName | Tagging | dev | true | string
| EnvironmentType | Tagging | development | true | string | ['development','production']
| VPCId | Security Groups | None | false | AWS::EC2::VPC::Id

## Outputs/Exports

| Name | Value | Exported |
| ---- | ----- | -------- |
| {function_name}SecurityGroup | The security group created for the function | true


## Included Components
[lib-ec2](https://github.com/theonestack/hl-component-lib-ec2)
[lib-iam](https://github.com/theonestack/hl-component-lib-iam)

## Example Configuration
### Highlander
```
  Component name: 'lambda', template: 'lambda'

```
### Lambda Configuration
```
functions:
  app1:
      handler: handler.lambda_handler
      runtime: python3.10
      code_uri: app1/src.zip
      timeout: 30
      environment:
        Environment: dev
      policies:
        logs:
          action:
            - logs:PutLogEvents
            - logs:DescribeLogStreams
            - logs:DescribeLogGroups
          resource:
            - '*'
      enable_eni: true
      log_retention: 7
      events:
        cron:
          type: schedule
          expression: cron(0 12 * * ? *)
          payload: "{ 'a': 1, 'b': 2 }"
        trigger:
          type: sns
```

## Cfhighlander Setup

install cfhighlander [gem](https://github.com/theonestack/cfhighlander)

```bash
gem install cfhighlander
```

or via docker

```bash
docker pull theonestack/cfhighlander
```
## Testing Components

Running the tests

```bash
cfhighlander cftest lambda
```