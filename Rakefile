require 'rake/clean'

EJABBERD_INSTALL = ENV["EJABBERD_INSTALL"] || "/opt/ejabberd"
ERLC = (ENV["ERL_TOP"] ? "#{ENV["ERL_TOP"]}/bin/erlc" : "erlc")
ERL = (ENV["ERL_TOP"] ? "#{ENV["ERL_TOP"]}/bin/erl" : "erl")
INCLUDES = "-I . -I #{EJABBERD_INSTALL}/lib/ejabberd/include -I #{EJABBERD_INSTALL}/lib/ejabberd/include/mod_muc -I #{EJABBERD_INSTALL}/lib/ejabberd/include/web -I #{EJABBERD_INSTALL}/lib/ejabberd/include/mod_pubsub -I #{EJABBERD_INSTALL}/lib/ejabberd/include"

ERLC_FLAGS = "#{INCLUDES} +warn_unused_vars +warn_unused_import"

FILES = Dir.new(".").select do |t| #
    File.directory? t and not ["ebin", "..", ".svn", ".git"].member? t  
end.map{|t| "#{t}/*.erl"}

SRC = FileList[FILES]
OBJ = SRC.pathmap("ebin/%n.beam")

CLEAN.include("ebin/*.beam")

directory 'ebin'

rule ".beam" => [
  proc {|targ|
      SRC.select {|f| f.pathmap("ebin/%n.beam") == targ }
    }
  ] do |t|
  sh "#{ERLC} -W #{ERLC_FLAGS} -o ebin #{t.source}"
end

desc "Compile les .erl dans le répertoire ebin/"
task :compile => ['ebin'] + OBJ

desc "Copie les beams vers #{EJABBERD_INSTALL}/lib/ejabberd/ebin"
task :install => ['ebin'] + OBJ do
  sh "cp ebin/*.beam #{EJABBERD_INSTALL}/lib/ejabberd/ebin"
end

task :default => :compile

task :test => [:compile] do 
  FileList["t/*.t"].each do |f|
    sh "prove -v #{f}"
  end
end