metadata  :name        => "sensu",
          :description => "sensu client action",
          :author      => "huhongbo",
          :license     => "GPLv2",
          :version     => "0.1",
          :url         => "https://github.com/huhongbo/chef-repo/cookbooks/mcollective-chef",
          :timeout     => 30

action "restart", :description => "sensu client restart" do
  display :always

  output :stdout,
        :description => "Standard output from the sensu-client init script",
        :display_as => "stdout"

    output :stderr,
        :description => "Error output from the sensu-client init script",
        :display_as => "stderr"

    output :output,
        :description => "The exit code set by the sensu-client init script after running the action.",
        :display_as => "exitcode"
end
