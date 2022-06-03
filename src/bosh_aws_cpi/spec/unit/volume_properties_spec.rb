require 'spec_helper'

module Bosh::AwsCloud
  describe VolumeProperties do
    let(:minimal_options) { {} }
    let(:maximal_options) do
      {
        size: 2048,
        type: 'io1',
        iops: 1,
        az: 'us-east-1a',
        encrypted: true,
        kms_key_arn: 'my_fake_kms_arn',
        root_device_name: '/dev/sda',
        # TODO: GX-7317: REVIEW: Is the tags test data below a valid example? It seems like tags should be an Array of Hashes with `key` and `value` keys (instead of `name` and `value` keys).
        # SEE: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/Volume.html#tags-instance_method
        # SEE: https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Volume.html
        # SEE: https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Tag.html
        tags: [{name: "foo", value: "bar"}]
      }
    end
    describe '#ephemeral_disk_config' do

      context 'given a minimal set of options' do
        subject(:volume_properties) {described_class.new(minimal_options)}
        it 'maps the properties to the disk' do
          vp = volume_properties.ephemeral_disk_config
          expect(vp).to eq(
            device_name: '/dev/sdb',
            ebs: {
              volume_size: 0,
              volume_type: 'gp3',
              delete_on_termination: true
            }
          )
        end
      end

      context 'given a maximal set of options' do
        subject(:volume_properties) {described_class.new(maximal_options)}
        it 'maps the properties to the disk' do
          vp = volume_properties.ephemeral_disk_config
          expect(vp).to eq(
            device_name: '/dev/sdb',
            ebs: {
              volume_size: 2,
              volume_type: 'io1',
              iops: 1,
              encrypted: true,
              kms_key_id: 'my_fake_kms_arn',
              delete_on_termination: true,
              # TODO: GX-7317: REVIEW: Why isn't a `:tag_specifications` included here? SEE: https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/42331379f1e4d1fe0caa7184ed6a98503341238e/src/bosh_aws_cpi/spec/unit/volume_properties_spec.rb#L79-L82
              # tag_specifications: [{
              #   resource_type: 'volume',
              #   tags: [{name: "foo", value: "bar"}]
              # }],
            }
          )
        end
      end
    end

    describe '#persistent_disk_config' do
      context 'given a minimal set of options' do
        subject(:volume_properties) {described_class.new(minimal_options)}
        it 'returns the correct persistent_disk_config' do
          vp = volume_properties.persistent_disk_config
          expect(vp).to eq(
            size: 0,
            availability_zone: nil,
            volume_type: 'gp3',
            encrypted: false,
          )
        end
      end

      context 'given a maximal set of options' do
        subject(:volume_properties) {described_class.new(maximal_options)}
        it 'returns the correct persistent_disk_config' do
          vp = volume_properties.persistent_disk_config
          expect(vp).to eq(
            size: 2,
            availability_zone: 'us-east-1a',
            volume_type: 'io1',
            encrypted: true,
            iops: 1,
            kms_key_id: 'my_fake_kms_arn',
            tag_specifications: [{
              resource_type: 'volume',
              tags: [{name: "foo", value: "bar"}]
            }]
          )
        end
      end
    end

    describe '#root_disk_config' do
      context 'given a minimal set of options' do
        subject(:volume_properties) {described_class.new(minimal_options)}
        it 'returns the correct root_disk_config' do
          vp = volume_properties.root_disk_config
          expect(vp).to eq(
            device_name: '/dev/xvda',
            ebs: {
              volume_type: 'gp3',
              delete_on_termination: true,
            }
          )
        end
      end

      context 'given a maximal set of options' do
        subject(:volume_properties) {described_class.new(maximal_options)}
        it 'returns the correct root_disk_config' do
          vp = volume_properties.root_disk_config
          expect(vp).to eq({
            device_name: '/dev/sda',
            ebs: {
              volume_size: 2,
              volume_type: 'io1',
              iops: 1,
              delete_on_termination: true,
              # TODO: GX-7317: REVIEW: Why isn't a `:tag_specifications` included here? SEE: https://github.com/cloudfoundry/bosh-aws-cpi-release/blob/42331379f1e4d1fe0caa7184ed6a98503341238e/src/bosh_aws_cpi/spec/unit/volume_properties_spec.rb#L79-L82
              # tag_specifications: [{
              #   resource_type: 'volume',
              #   tags: [{name: "foo", value: "bar"}]
              # }],
            }
          })
        end
      end
    end
  end
end
