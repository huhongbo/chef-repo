metadata    :name        => "run chef echo",
		    :description => "run info agent output",
        	:author      => "dn365",
	        :license     => "GPLv2",
            :version     => "0.1",
            :url         => "https://github.com/dn365/mcollective-chef",
            :timeout     => 300

action "run", :description => "chef client run" do
	display :always
	
	output :stdout,
        :description => "Standard output from the chef-client init script",
        :display_as => "stdout"

    output :stderr,
        :description => "Error output from the chef-client init script",
        :display_as => "stderr"

    output :output,
        :description => "The exit code set by the chef-client init script after running the action.",
        :display_as => "exitcode"
end