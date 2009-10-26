#!/usr/bin/env escript
%% -*- erlang -*-
%%! -pa ./ebin  -boot start_sasl -noshell -pz /opt/ejabberd/lib/ejabberd/ebin/

%% -kernel error_logger silent 
main(_)->
  etap:plan(7),
  etap:diag("Testing the mod_echo module."),
  mock:start(),
  
  ejabberd_loglevel:set(0), % Initiates logger
  mock:add_module(ejabberd_router),
  mock:set_answer(ejabberd_router, register_route, ok),
  mock:set_answer(ejabberd_router, unregister_route, ok),
  mock:set_answer(ejabberd_router, route, ok),
  stringprep:start(),
  
  {ok, Pid} = mod_echo:start_link("boulette.local", []),
  etap:ok(erlang:is_process_alive(Pid), "mod_echo running"),
  
  etap:is(mock:calls(), [{ejabberd_router,register_route,["echo.boulette.local"]}], "route registered ok"),
  From = "cstar@boulette.local/cstar",
  FJID = jlib:string_to_jid(From),
  To = "echo.boulette.local",
  Packet = {xmlelement,"message", [], []},
  TJID = jlib:string_to_jid(To),
  Pid ! {route, FJID, TJID, Packet},
  %% wait a bit, make sure component has processed message
  timer:sleep(100),
  etap:is(mock:calls(), [{ejabberd_router,route,[ 
                TJID, 
                FJID,  
                Packet]}], "echo sent ok"),
  
  From2 = "boulette.local/cstar",
  Pid ! {route, jlib:string_to_jid(From2), TJID, Packet},
  timer:sleep(100),
  etap:is(mock:calls(), [{ejabberd_router,route,[ 
                TJID, 
                jlib:string_to_jid(From2),  
                make_error()]}], "Error returned"),
  gen_server:call(Pid, stop),
  
  %% Restart but with version validation
  {ok, Pid2} = mod_echo:start_link("boulette.local", [{version, enabled}]),
  %% Emptying call buffer
  mock:calls(),
  
  Pid2 ! {route, FJID, TJID, Packet},
  timer:sleep(100),
  %% Is a jabber:iq:version sent ?
  Version = {xmlelement,"iq",[{"to",From},{"type","get"}],
              [{xmlelement,"query", [{"xmlns","jabber:iq:version"}], []}]},
  [{ejabberd_router,route,[F, T, P]}] = mock:calls(),
  {"", To, Resource} = jlib:jid_tolower(F), % not etap'ed, room for improvement here
  etap:is({T, P}, {FJID, Version},  "Valid IQ version is sent to client"),
  
  mock:add_module(ejabberd_logger),
  mock:set_answer(ejabberd_logger, info_msg, ok),
  
  VersionReply = {xmlelement,"iq",[{"type","result"}],
              [{xmlelement,"query", [{"xmlns","jabber:iq:version"}], [
              {xmlelement,"Name",[],[{xmlcdata,<<"etap test framwork">>}]}]}]},
  Pid2 ! {route, jlib:string_to_jid(From), jlib:make_jid("", To, Resource), VersionReply},
  timer:sleep(100),

  lists:map(
    fun({ejabberd_logger, info_msg, Args})->
          etap:is(Args,[mod_echo,203,"Information of the client: ~s~s",
                       ["cstar@boulette.local/cstar",
                        ["\n","Name",58,32,
                         [60,60,"\"etap test framwork\"",62,62]]]], "data written in log");
      ({ejabberd_router,route,Args})->
        etap:is(Args, [TJID, FJID, Packet], "received echo packet")
    end,
  mock:calls()),
  etap:end_tests().
  
make_error()->
  {xmlelement,"message",
      [{"type","error"}],
      [{xmlelement,"error",
      [{"code","400"},{"type","modify"}],
      [{xmlelement,"bad-request",
      [{"xmlns",
        "urn:ietf:params:xml:ns:xmpp-stanzas"}],
      []}]}]}.
