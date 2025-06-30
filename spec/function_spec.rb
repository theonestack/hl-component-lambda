require 'yaml'

describe 'compiled component lambda' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/function.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/function/lambda.compiled.yaml") }
  
  context "Resource" do

    
    context "myfunctionRole" do
      let(:resource) { template["Resources"]["myfunctionRole"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"lambda.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq("/")
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"logs", "PolicyDocument"=>{"Statement"=>[{"Sid"=>"logs", "Action"=>["logs:PutLogEvents", "logs:DescribeLogStreams", "logs:DescribeLogGroups"], "Resource"=>["*"], "Effect"=>"Allow"}]}}])
      end
      
    end
    
    context "myfunctionSecurityGroup" do
      let(:resource) { template["Resources"]["myfunctionSecurityGroup"] }

      it "is of type AWS::EC2::SecurityGroup" do
          expect(resource["Type"]).to eq("AWS::EC2::SecurityGroup")
      end
      
      it "to have property GroupDescription" do
          expect(resource["Properties"]["GroupDescription"]).to eq({"Fn::Sub"=>"${EnvironmentName}-lambda-myfunction"})
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPCId"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "myfunction" do
      let(:resource) { template["Resources"]["myfunction"] }

      it "is of type AWS::Lambda::Function" do
          expect(resource["Type"]).to eq("AWS::Lambda::Function")
      end
      
      it "to have property Code" do
          expect(resource["Properties"]["Code"]).to eq({"S3Bucket"=>"source.example.dev", "S3Key"=>{"Fn::Sub"=>"/lambda/myfunction/src.zip"}})
      end
      
      it "to have property Environment" do
          expect(resource["Properties"]["Environment"]).to eq({"Variables"=>{"Environment"=>"dev"}})
      end
      
      it "to have property Handler" do
          expect(resource["Properties"]["Handler"]).to eq("handler.lambda_handler")
      end
      
      it "to have property MemorySize" do
          expect(resource["Properties"]["MemorySize"]).to eq(128)
      end
      
      it "to have property Role" do
          expect(resource["Properties"]["Role"]).to eq({"Fn::GetAtt"=>["myfunctionRole", "Arn"]})
      end
      
      it "to have property Runtime" do
          expect(resource["Properties"]["Runtime"]).to eq("python3.10")
      end
      
      it "to have property Timeout" do
          expect(resource["Properties"]["Timeout"]).to eq(30)
      end
      
      it "to have property VpcConfig" do
          expect(resource["Properties"]["VpcConfig"]).to eq({"SecurityGroupIds"=>[{"Ref"=>"myfunctionSecurityGroup"}], "SubnetIds"=>{"Fn::If"=>["4SubnetCompute", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}, {"Ref"=>"SubnetCompute2"}, {"Ref"=>"SubnetCompute3"}, {"Ref"=>"SubnetCompute4"}], {"Fn::If"=>["3SubnetCompute", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}, {"Ref"=>"SubnetCompute2"}, {"Ref"=>"SubnetCompute3"}], {"Fn::If"=>["2SubnetCompute", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}, {"Ref"=>"SubnetCompute2"}], {"Fn::If"=>["1SubnetCompute", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}], {"Ref"=>"SubnetCompute1"}]}]}]}]}})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
      it "to have property Layers" do
          expect(resource["Properties"]["Layers"]).to eq(["arn:aws:lambda:us-east-1:123456789012:layer:my-layer:1"])
      end
      
    end
    
    context "myfunctionLogGroup" do
      let(:resource) { template["Resources"]["myfunctionLogGroup"] }

      it "is of type AWS::Logs::LogGroup" do
          expect(resource["Type"]).to eq("AWS::Logs::LogGroup")
      end
      
      it "to have property LogGroupName" do
          expect(resource["Properties"]["LogGroupName"]).to eq({"Fn::Sub"=>"/aws/lambda/${EnvironmentName}/myfunction"})
      end
      
      it "to have property RetentionInDays" do
          expect(resource["Properties"]["RetentionInDays"]).to eq(7)
      end
      
    end
    
    context "myfunctionSchedulecron" do
      let(:resource) { template["Resources"]["myfunctionSchedulecron"] }

      it "is of type AWS::Events::Rule" do
          expect(resource["Type"]).to eq("AWS::Events::Rule")
      end
      
      it "to have property ScheduleExpression" do
          expect(resource["Properties"]["ScheduleExpression"]).to eq("cron(0 12 * * ? *)")
      end
      
      it "to have property State" do
          expect(resource["Properties"]["State"]).to eq("ENABLED")
      end
      
      it "to have property Targets" do
          expect(resource["Properties"]["Targets"]).to eq([{"Arn"=>{"Fn::GetAtt"=>["myfunction", "Arn"]}, "Id"=>"lambdamyfunction", "Input"=>"{ 'a': 1, 'b': 2 }"}])
      end
      
    end
    
    context "myfunctioncronPermissions" do
      let(:resource) { template["Resources"]["myfunctioncronPermissions"] }

      it "is of type AWS::Lambda::Permission" do
          expect(resource["Type"]).to eq("AWS::Lambda::Permission")
      end
      
      it "to have property FunctionName" do
          expect(resource["Properties"]["FunctionName"]).to eq({"Ref"=>"myfunction"})
      end
      
      it "to have property Action" do
          expect(resource["Properties"]["Action"]).to eq("lambda:InvokeFunction")
      end
      
      it "to have property Principal" do
          expect(resource["Properties"]["Principal"]).to eq("events.amazonaws.com")
      end
      
      it "to have property SourceArn" do
          expect(resource["Properties"]["SourceArn"]).to eq({"Fn::GetAtt"=>["myfunctionSchedulecron", "Arn"]})
      end
      
    end
    
    context "myfunctionSnstrigger" do
      let(:resource) { template["Resources"]["myfunctionSnstrigger"] }

      it "is of type AWS::SNS::Topic" do
          expect(resource["Type"]).to eq("AWS::SNS::Topic")
      end
      
      it "to have property Subscription" do
          expect(resource["Properties"]["Subscription"]).to eq([{"Endpoint"=>{"Fn::GetAtt"=>["myfunction", "Arn"]}, "Protocol"=>"lambda"}])
      end
      
    end
    
    context "myfunctiontriggerPermissions" do
      let(:resource) { template["Resources"]["myfunctiontriggerPermissions"] }

      it "is of type AWS::Lambda::Permission" do
          expect(resource["Type"]).to eq("AWS::Lambda::Permission")
      end
      
      it "to have property FunctionName" do
          expect(resource["Properties"]["FunctionName"]).to eq({"Ref"=>"myfunction"})
      end
      
      it "to have property Action" do
          expect(resource["Properties"]["Action"]).to eq("lambda:InvokeFunction")
      end
      
      it "to have property Principal" do
          expect(resource["Properties"]["Principal"]).to eq("sns.amazonaws.com")
      end
      
      it "to have property SourceArn" do
          expect(resource["Properties"]["SourceArn"]).to eq({"Ref"=>"myfunctionSnstrigger"})
      end
      
    end
    
  end

end