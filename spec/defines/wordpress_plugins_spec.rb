require 'spec_helper'

describe 'wordpress::wp_plugin' do
  let  :default_params do
    {
      :zip_url        => 'https://downloads.wordpress.org/plugin/custom-content-shortcode.2.1.3.zip',
      :zip_filename   => 'custom-content-shortcode.2.1.3.zip',
      :install_dir => '/opt/wordpress',
      :wp_owner       => 'apache',
      :wp_group       => 'apache',
    }
  end

  context "With default parameters" do
    let(:title) { 'custom-content-shortcode'}
    let :params do
      default_params
    end

    it do
      should contain_exec('download-wordpress-plugin-custom-content-shortcode').with({
        :command => "/usr/bin/wget -nc https://downloads.wordpress.org/plugin/custom-content-shortcode.2.1.3.zip"
      })
    end

    it do
      should contain_exec('extract-wordpress-plugin-custom-content-shortcode').with({
        :command => "unzip ./custom-content-shortcode.2.1.3.zip"
      })
    end
  end
end
