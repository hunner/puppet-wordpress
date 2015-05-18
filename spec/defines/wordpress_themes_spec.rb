require 'spec_helper'

describe 'wordpress::wp_theme' do
  let  :default_params do
    {
      :tar_url        => 'http://gitlab.csedigital.com/dyoung/ajc-breakdown/repository/archive.tar.gz?ref=master',
      :tar_filename   => 'breakdown.tar.gz',
      :install_dir => '/opt/wordpress',
      :wp_owner       => 'apache',
      :wp_group       => 'apache',
    }
  end

  context "With default parameters" do
    let(:title) { 'breakdown'}
    let :params do
      default_params
    end

    it do
      should contain_file('/opt/wordpress/wp-content/themes/breakdown')
    end

    it do
      should contain_exec('download-wordpress-theme-breakdown').with({
        :command => "/usr/bin/curl -o breakdown.tar.gz -L http://gitlab.csedigital.com/dyoung/ajc-breakdown/repository/archive.tar.gz?ref=master"
      })
    end

    it do
      should contain_exec('extract-wordpress-theme-breakdown').with({
        :command => "tar --strip-components=0 -xf ./breakdown.tar.gz"
      })
    end
  end
end
