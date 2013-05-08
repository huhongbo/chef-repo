metadata    :name        => "Run shell commands, get output",
            :description => "run arbitrary shell commands and get their output",
            :author      => "joe miller",
            :license     => "GPLv2",
            :version     => "1.0",
            :url         => "http://github.com/joemiller/shellcmd-agent",
            :timeout     => 300

action "runcmd", :description => "rum shell cmd" do
	display :always
	
	input :cmd,
		  :prompt => "shell name",
		  :description => "run arbitrary shell commands",
		  :type => :string,
		  :validation => '^.+$',
		  :optional => false,
		  :maxlength => 60
	output :output,
			:description => "cmd outpus info",
			:display_as => "output"
	output :exitcode,
			:description => "cmd exit code info",
			:display_as => "exitcode"
end