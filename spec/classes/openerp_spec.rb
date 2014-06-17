require 'spec_helper'

describe 'openerp' do
  context 'on Debian wheezy' do
    let(:facts) {{
      :concat_basedir         => tmpfilename('openerp'),
      :id                     => 'root',
      :kernel                 => 'Linux',
      :lsbdistcodename        => 'wheezy',
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => '7.5',
      :osfamily               => 'Debian',
      :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }}
    let :pre_condition do
      "include ::postgresql::server"
    end
    context 'with no parameters' do
      it { should compile.with_all_deps }
    end
  end
end
