%% @author Tomas S�vstr�m <tosa7943@student.uu.se>
%% [www.csproj13.student.it.uu.se]
%% @version 1.0
%% @copyright [Copyright information]
%%
%% @doc == triggers_tests ==
%% This module contains several tests to test the functionallity
%% in the module triggers which is done by calling the webbmachine.
%%
%% @end

-module(triggers_tests).
-include_lib("eunit/include/eunit.hrl").
-include("debug.hrl").
-include_lib("amqp_client.hrl").
-export([]).

-define(WEBMACHINE_URL, api_help:get_webmachine_url()).
-define(ES_URL, api_help:get_elastic_search_url()).
%% @doc
%% Function: inti_test/0
%% Purpose: Used to start the inets to be able to do HTTP requests
%% Returns: ok | {error, term()}
%%
%% Side effects: Start inets
%% @end
-spec init_test() -> ok | {error, term()}.

init_test() ->
	inets:start().


%% @doc
%% Function: create_delete_test/0
%% Purpose: Test the process_post and delete_resource functions by doing some HTTP requests
%% Returns: ok | {error, term()}
%% @end
create_delete_test() -> 
	%% Create
	{ok, {{_VersionU1, 200, _ReasonPhraseU1}, _HeadersU1, BodyU1}} = httpc:request(post, {?WEBMACHINE_URL++"/users", [],"application/json", "{\"username\" : \"Tomas\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version1, 200, _ReasonPhrase1}, _Headers1, Body1}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"test\",\"input\":5,\"streams\":\"test\"}"}, [], []),
	DocId1 = lib_json:get_field(Body1,"_id"),
	api_help:refresh(),
	{ok, {{_Version2, 200, _ReasonPhrase2}, _Headers2, Body2}} = httpc:request(get, {?ES_URL++"/sensorcloud/trigger/" ++ lib_json:to_string(DocId1), []}, [], []),
	api_help:refresh(),
	{ok, {{_Version3, 200, _ReasonPhrase3}, _Headers3, Body3}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"test\",\"input\":5,\"streams\":\"test\"}"}, [], []),
	DocId2 = lib_json:get_field(Body3,"_id"),
	api_help:refresh(),
	{ok, {{_Version4, 200, _ReasonPhrase4}, _Headers4, Body4}} = httpc:request(get, {?ES_URL++"/sensorcloud/trigger/" ++ lib_json:to_string(DocId2), []}, [], []),
	api_help:refresh(),
	{ok, {{_Version5, 200, _ReasonPhrase5}, _Headers5, Body5}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"test\",\"input\":6,\"streams\":\"test\"}"}, [], []),
	DocId3 = lib_json:get_field(Body5,"_id"),
	api_help:refresh(),
	{ok, {{_Version6, 200, _ReasonPhrase6}, _Headers6, Body6}} = httpc:request(get, {?ES_URL++"/sensorcloud/trigger/" ++ lib_json:to_string(DocId3), []}, [], []),
	api_help:refresh(),
	{ok, {{_Version7, 200, _ReasonPhrase7}, _Headers7, Body7}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"test\",\"input\":6,\"streams\":[\"test\",\"test2\"]}"}, [], []),
	DocId4 = lib_json:get_field(Body7,"_id"),
	api_help:refresh(),
	{ok, {{_Version8, 200, _ReasonPhrase8}, _Headers8, Body8}} = httpc:request(get, {?ES_URL++"/sensorcloud/trigger/" ++ lib_json:to_string(DocId4), []}, [], []),
	api_help:refresh(),
	
	%% Create tests
	?assertEqual(lib_json:get_field(Body2,"_source"),lib_json:get_field(Body4,"_source")),
	?assertEqual(DocId1,DocId3),
	?assertNotEqual(DocId1,DocId4),
	?assertEqual(true,lib_json:field_value_exists(Body6,"_source.outputlist[*].input",5)),
	?assertEqual(true,lib_json:field_value_exists(Body6,"_source.outputlist[*].input",6)),
	
	
	
	%% Delete 
	{ok, {{_Version9, 200, _ReasonPhrase9}, _Headers9, Body9}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"test\",\"input\":5,\"streams\":\"test\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version10, 200, _ReasonPhrase10}, _Headers10, Body10}} = httpc:request(get, {?ES_URL++"/sensorcloud/trigger/" ++ lib_json:to_string(DocId1), []}, [], []),
	api_help:refresh(),
	{ok, {{_Version11, 200, _ReasonPhrase11}, _Headers11, Body11}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"test\",\"input\":6,\"streams\":\"test\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version12, 200, _ReasonPhrase12}, _Headers12, Body12}} = httpc:request(get, {?ES_URL++"/sensorcloud/trigger/" ++ lib_json:to_string(DocId3), []}, [], []),
	api_help:refresh(),
	{ok, {{_Version13, 200, _ReasonPhrase13}, _Headers13, Body13}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"test\",\"input\":6,\"streams\":[\"test\",\"test2\"]}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version14, 200, _ReasonPhrase14}, _Headers14, Body14}} = httpc:request(get, {?ES_URL++"/sensorcloud/trigger/" ++ lib_json:to_string(DocId4), []}, [], []),
	api_help:refresh(),
	{ok, {{_VersionU2, 200, _ReasonPhraseU2}, _HeadersU2, BodyU2}} = httpc:request(delete, {?WEBMACHINE_URL++"/users/Tomas", []}, [], []),
	api_help:refresh(),
	%% Delete tests
	?assertEqual(true,(lib_json:get_field(Body12,"exist") == false) or (lib_json:get_field(Body12,"_source.outputlist") == [])), %% Answer will depend on how quick messages to the triggersProcess are
	?assertEqual(true,(lib_json:get_field(Body14,"exist") == false) or (lib_json:get_field(Body14,"_source.outputlist") == [])). %% Answer will depend on how quick messages to the triggersProcess are



%% @doc
%% Function: post_data_test/0
%% Purpose: Test the triggersProcess by doing some posting for data to
%%          the streams the trigger is on
%% Returns: ok | {error, term()}
%% @end
post_data_exhange_test() ->
	User1 = "tomas",
	User2 = "erik",
        httpc:request(post, {?WEBMACHINE_URL++"/users", [],"application/json", "{\"username\" : \"Tomas\"}"}, [], []),
        httpc:request(post, {?WEBMACHINE_URL++"/users", [],"application/json", "{\"username\" : \"Erik\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version1, 200, _ReasonPhrase1}, _Headers1, Body1}} = httpc:request(post, {?WEBMACHINE_URL++"/streams", [],"application/json", "{\"name\" : \"Stream1\",\"user_id\":\"Tomas\"}"}, [], []),
	{ok, {{_Version2, 200, _ReasonPhrase2}, _Headers2, Body2}} = httpc:request(post, {?WEBMACHINE_URL++"/streams", [],"application/json", "{\"name\" : \"Stream2\",\"user_id\":\"Tomas\"}"}, [], []),
	StreamId1 = lib_json:get_field(Body1,"_id"),
	StreamId2 = lib_json:get_field(Body2,"_id"),
	api_help:refresh(),
	%% Create
	{ok, {{_Version3, 200, _ReasonPhrase3}, _Headers3, Body3}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"less_than\",\"input\":5,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	TriggerId1 = lib_json:get_field(Body3, "_id"),
	api_help:refresh(),
	{ok, {{_Version4, 200, _ReasonPhrase4}, _Headers4, Body4}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Erik/triggers/add", [],"application/json", "{\"function\" : \"less_than\",\"input\":5,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version5, 200, _ReasonPhrase5}, _Headers5, Body5}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"less_than\",\"input\":10,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version6, 200, _ReasonPhrase6}, _Headers6, Body6}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"less_than\",\"input\":6,\"streams\":[\"" ++ lib_json:to_string(StreamId1) ++"\",\"" ++ lib_json:to_string(StreamId2) ++"\"]}"}, [], []),
	TriggerId2 = lib_json:get_field(Body6, "_id"),
	api_help:refresh(),
	
	%% Connect.
	{ok, Connection} =
		amqp_connection:start(#amqp_params_network{}),
	
	%% Open In and OUT channels.
	{ok, ChannelIn} = amqp_connection:open_channel(Connection),
	InputExchanges = [list_to_binary("trigger." ++ lib_json:to_string(TriggerId1)),list_to_binary("trigger." ++ lib_json:to_string(TriggerId2))],
	triggersProcess:subscribe(ChannelIn, InputExchanges),
	
	{ok, {{_Version7, 200, _ReasonPhrase7}, _Headers7, Body7}} = httpc:request(post, {?WEBMACHINE_URL++"/streams/" ++ lib_json:to_string(StreamId1) ++"/data", [],"application/json", "{\"value\" : 4}"}, [], []),
	{ok, {{_Version8, 200, _ReasonPhrase8}, _Headers8, Body8}} = httpc:request(post, {?WEBMACHINE_URL++"/streams/" ++ lib_json:to_string(StreamId1) ++"/data", [],"application/json", "{\"value\" : 7}"}, [], []),
	{ok, {{_Version9, 200, _ReasonPhrase9}, _Headers9, Body9}} = httpc:request(post, {?WEBMACHINE_URL++"/streams/" ++ lib_json:to_string(StreamId2) ++"/data", [],"application/json", "{\"value\" : 4}"}, [], []),
	
	Messages = [{4,lib_json:to_string(StreamId1),5,[{user,User2},{user,User1}]},{4,lib_json:to_string(StreamId1),10,[{user,User1}]},{4,lib_json:to_string(StreamId1),6,[{user,User1}]},{7,lib_json:to_string(StreamId1),10,[{user,User1}]},{4,lib_json:to_string(StreamId2),6,[{user,User1}]}],
	receive_loop(Messages),
	amqp_channel:close(ChannelIn),
	amqp_connection:close(Connection),

	{ok, {{_Version10, 200, _ReasonPhrase10}, _Headers10, Body10}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"less_than\",\"input\":5,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version11, 200, _ReasonPhrase11}, _Headers11, Body11}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Erik/triggers/remove", [],"application/json", "{\"function\" : \"less_than\",\"input\":5,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version12, 200, _ReasonPhrase12}, _Headers12, Body12}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"less_than\",\"input\":10,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version13, 200, _ReasonPhrase13}, _Headers13, Body13}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"less_than\",\"input\":6,\"streams\":[\"" ++ lib_json:to_string(StreamId1) ++"\",\"" ++ lib_json:to_string(StreamId2) ++"\"]}"}, [], []),
	api_help:refresh(),
	{ok, {{_VersionU3, 200, _ReasonPhraseU3}, _HeadersU3, BodyU3}} = httpc:request(delete, {?WEBMACHINE_URL++"/users/Tomas", []}, [], []),
	{ok, {{_VersionU4, 200, _ReasonPhraseU4}, _HeadersU4, BodyU4}} = httpc:request(delete, {?WEBMACHINE_URL++"/users/Erik", []}, [], []),
	api_help:refresh().


%% @doc
%% Function: post_data_test/0
%% Purpose: Test the triggersProcess by doing some posting for data to
%%          the streams the trigger is on
%% Returns: ok | {error, term()}
%% @end
post_data_user_test() ->
	User1 = "tomas",
	User2 = "erik",
    httpc:request(post, {?WEBMACHINE_URL++"/users", [],"application/json", "{\"username\" : \""++User1++"\"}"}, [], []),
    httpc:request(post, {?WEBMACHINE_URL++"/users", [],"application/json", "{\"username\" : \""++User2++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version1, 200, _ReasonPhrase1}, _Headers1, Body1}} = httpc:request(post, {?WEBMACHINE_URL++"/streams", [],"application/json", "{\"name\" : \"Stream1\",\"user_id\":\"Tomas\"}"}, [], []),
	{ok, {{_Version2, 200, _ReasonPhrase2}, _Headers2, Body2}} = httpc:request(post, {?WEBMACHINE_URL++"/streams", [],"application/json", "{\"name\" : \"Stream2\",\"user_id\":\"Tomas\"}"}, [], []),
	StreamId1 = lib_json:get_field(Body1,"_id"),
	StreamId2 = lib_json:get_field(Body2,"_id"),
	api_help:refresh(),
	%% Create
	{ok, {{_Version3, 200, _ReasonPhrase3}, _Headers3, Body3}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"less_than\",\"input\":5,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	TriggerId1 = lib_json:get_field(Body3, "_id"),
	api_help:refresh(),
	{ok, {{_Version4, 200, _ReasonPhrase4}, _Headers4, Body4}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Erik/triggers/add", [],"application/json", "{\"function\" : \"less_than\",\"input\":5,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version5, 200, _ReasonPhrase5}, _Headers5, Body5}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"less_than\",\"input\":10,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version6, 200, _ReasonPhrase6}, _Headers6, Body6}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/add", [],"application/json", "{\"function\" : \"less_than\",\"input\":6,\"streams\":[\"" ++ lib_json:to_string(StreamId1) ++"\",\"" ++ lib_json:to_string(StreamId2) ++"\"]}"}, [], []),
	TriggerId2 = lib_json:get_field(Body6, "_id"),
	api_help:refresh(),
	
	
	{ok, {{_Version7, 200, _ReasonPhrase7}, _Headers7, Body7}} = httpc:request(post, {?WEBMACHINE_URL++"/streams/" ++ lib_json:to_string(StreamId1) ++"/data", [],"application/json", "{\"value\" : 4}"}, [], []),
	{ok, {{_Version8, 200, _ReasonPhrase8}, _Headers8, Body8}} = httpc:request(post, {?WEBMACHINE_URL++"/streams/" ++ lib_json:to_string(StreamId1) ++"/data", [],"application/json", "{\"value\" : 7}"}, [], []),
	{ok, {{_Version9, 200, _ReasonPhrase9}, _Headers9, Body9}} = httpc:request(post, {?WEBMACHINE_URL++"/streams/" ++ lib_json:to_string(StreamId2) ++"/data", [],"application/json", "{\"value\" : 4}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version10, 200, _ReasonPhrase10}, _Headers10, Body10}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"less_than\",\"input\":5,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version11, 200, _ReasonPhrase11}, _Headers11, Body11}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Erik/triggers/remove", [],"application/json", "{\"function\" : \"less_than\",\"input\":5,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version12, 200, _ReasonPhrase12}, _Headers12, Body12}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"less_than\",\"input\":10,\"streams\":\"" ++ lib_json:to_string(StreamId1) ++"\"}"}, [], []),
	api_help:refresh(),
	{ok, {{_Version13, 200, _ReasonPhrase13}, _Headers13, Body13}} = httpc:request(post, {?WEBMACHINE_URL++"/users/Tomas/triggers/remove", [],"application/json", "{\"function\" : \"less_than\",\"input\":6,\"streams\":[\"" ++ lib_json:to_string(StreamId1) ++"\",\"" ++ lib_json:to_string(StreamId2) ++"\"]}"}, [], []),
	api_help:refresh(),
	timer:sleep(3000),
	{ok, {{_VersionU3, 200, _ReasonPhraseU3}, _HeadersU3, BodyU3}} = httpc:request(get, {?WEBMACHINE_URL++"/users/Tomas", []}, [], []),
	{ok, {{_VersionU4, 200, _ReasonPhraseU4}, _HeadersU4, BodyU4}} = httpc:request(get, {?WEBMACHINE_URL++"/users/Erik", []}, [], []),
	api_help:refresh(),
	{ok, {{_VersionU5, 200, _ReasonPhraseU5}, _HeadersU5, BodyU5}} = httpc:request(delete, {?WEBMACHINE_URL++"/users/Tomas", []}, [], []),
	{ok, {{_VersionU6, 200, _ReasonPhraseU6}, _HeadersU6, BodyU6}} = httpc:request(delete, {?WEBMACHINE_URL++"/users/Erik", []}, [], []),
	NotificationList1 = lists:map(fun(A) -> lib_json:rm_field(A, "trigger.timestamp") end,lib_json:get_field(BodyU3,"notifications")),
	NotificationList2 = lists:map(fun(A) -> lib_json:rm_field(A, "trigger.timestamp") end,lib_json:get_field(BodyU4,"notifications")),
	ReferenceList1 = ["{\"trigger\":{\"input\":10,\"stream_id\":\"" ++ lib_json:to_string(StreamId1) ++"\",\"trigger_id\":\"" ++ lib_json:to_string(TriggerId1) ++ "\",\"value\":4}}",
					  "{\"trigger\":{\"input\":5,\"stream_id\":\"" ++ lib_json:to_string(StreamId1) ++"\",\"trigger_id\":\"" ++ lib_json:to_string(TriggerId1) ++ "\",\"value\":4}}",
					  "{\"trigger\":{\"input\":10,\"stream_id\":\"" ++ lib_json:to_string(StreamId1) ++"\",\"trigger_id\":\"" ++ lib_json:to_string(TriggerId1) ++ "\",\"value\":7}}",
					  "{\"trigger\":{\"input\":6,\"stream_id\":\"" ++ lib_json:to_string(StreamId2) ++"\",\"trigger_id\":\"" ++ lib_json:to_string(TriggerId2) ++ "\",\"value\":4}}",
					  "{\"trigger\":{\"input\":6,\"stream_id\":\"" ++ lib_json:to_string(StreamId1) ++"\",\"trigger_id\":\"" ++ lib_json:to_string(TriggerId2) ++ "\",\"value\":4}}",
					  "{\"trigger\":{\"input\":6,\"stream_id\":\"" ++ lib_json:to_string(StreamId2) ++"\",\"trigger_id\":\"" ++ lib_json:to_string(TriggerId2) ++ "\",\"value\":4}}",
					  "{\"trigger\":{\"input\":6,\"stream_id\":\"" ++ lib_json:to_string(StreamId2) ++"\",\"trigger_id\":\"" ++ lib_json:to_string(TriggerId2) ++ "\",\"value\":4}}"],
	ReferenceList2 = ["{\"trigger\":{\"input\":5,\"stream_id\":\"" ++ lib_json:to_string(StreamId1) ++"\",\"trigger_id\":\"" ++ lib_json:to_string(TriggerId1) ++ "\",\"value\":4}}"],
	?assertEqual(true, check_all_exist(NotificationList1,ReferenceList1)),
	?assertEqual(true, check_all_exist(NotificationList2,ReferenceList2)).


list_triggers_test_() ->
    Descript1 = "Testing listing of triggers",
    Setup1 = 
	fun() ->
		UserId1 = "tommy",
		%% Create users
		httpc:request(post,{?WEBMACHINE_URL++"/users",[],"application/json","{\"username\":\""++UserId1++"\"}"},[],[]),
		%% Create streams
		{ok,{{_,200,_},_,Body1}} = 
		    httpc:request(post,{?WEBMACHINE_URL++"/streams",[],"application/json",
					"{\"name\":\"Stream1\",\"user_id\":\""++UserId1++"\"}"},[],[]),
		{ok,{{_,200,_},_,Body2}} = 
		    httpc:request(post,{?WEBMACHINE_URL++"/streams",[],"application/json",
					"{\"name\":\"Stream2\",\"user_id\":\""++UserId1++"\"}"},[],[]),
		api_help:refresh(),
		StreamId1 = lib_json:to_string(lib_json:get_field(Body1,"_id")),
		StreamId2 = lib_json:to_string(lib_json:get_field(Body2,"_id")),
		%% Create a trigger
		{ok,{{_,200,_},_,_}} = httpc:request(post,{?WEBMACHINE_URL++"/users/"++UserId1++"/triggers/add",[],
							       "application/json",
							       "{\"function\" : \"less_than\",\"input\":5,\"streams\":[\"" 
							       ++ StreamId1 ++ "\",\""++StreamId2 ++"\"]}"}, [], []),
		{ok,{{_,200,_},_,_}} = httpc:request(post,{?WEBMACHINE_URL++"/users/"++UserId1++"/triggers/add",[],
							       "application/json",
							       "{\"function\" : \"less_than\",\"input\":4,\"streams\":\"" 
							       ++ StreamId2 ++"\"}"}, [], []),
		api_help:refresh(),
		{UserId1, StreamId1, StreamId2}
	end,
    Cleanup1 =
	fun({UserId1, StreamId1, StreamId2}) ->
		{ok,{{_,200,_},_,_}} = httpc:request(post,{?WEBMACHINE_URL++"/users/"++UserId1++"/triggers/remove",[],
							   "application/json",
							   "{\"function\" : \"less_than\",\"input\":5,\"streams\":[\"" 
							   ++ StreamId1 ++ "\",\""++StreamId2 ++"\"]}"}, [], []),
		{ok,{{_,200,_},_,_}} = httpc:request(post,{?WEBMACHINE_URL++"/users/"++UserId1++"/triggers/remove",[],
							       "application/json",
							       "{\"function\" : \"less_than\",\"input\":4,\"streams\":\"" 
							       ++StreamId2 ++"\"}"}, [], []),
		{ok,{{_,200,_},_,_}} = httpc:request(delete,{?WEBMACHINE_URL++"/streams/"++StreamId1,[]},[],[]),
		{ok,{{_,200,_},_,_}} = httpc:request(delete,{?WEBMACHINE_URL++"/streams/"++StreamId2,[]},[],[]),
		{ok,{{_,200,_},_,_}} = httpc:request(delete,{?WEBMACHINE_URL++"/users/"++UserId1,[]},[],[])
	end,
    Tests1 = fun list_triggers/1,
    {Descript1,{setup, Setup1, Cleanup1, Tests1}}.


list_triggers({UserId1, StreamId1, StreamId2}) ->
    {ok,{{_,200,_},_,Body1}} = httpc:request(get, {?WEBMACHINE_URL++"/users/"++UserId1++"/triggers", []}, [], []),
    {ok,{{_,200,_},_,Body2}} = httpc:request(get, {?WEBMACHINE_URL++"/users/"++UserId1++"/streams/"
							    ++StreamId2++"/triggers", []}, [], []),
    {ok,{{_,200,_},_,Body3}} = httpc:request(get, {?WEBMACHINE_URL++"/users/"++UserId1++"/streams/"
							    ++StreamId1++"/triggers", []}, [], []),
    Result1 = 
	"{\"triggers\":[{\"function\":\"less_than\",\"input\":5,\"streams\":[\""++StreamId1++"\",\""++StreamId2++"\"]},"
	"{\"function\":\"less_than\",\"input\":4,\"streams\":[\""++StreamId2++"\"]}]}",
    Result2 = "{\"triggers\":[{\"function\":\"less_than\",\"input\":5,\"streams\":[\""++StreamId1++"\",\""++StreamId2++"\"]}]}",
    [?_assertEqual(Result1, Body1),
     ?_assertEqual(Result1, Body2),
     ?_assertEqual(Result2, Body3)].
    

%% @doc
%% Function: post_data_test/0
%% Purpose: Test the triggersProcess by doing some posting for data to
%%          the streams the trigger is on
%% Returns: ok | {error, term()}
%% @end
post_data_uri_test() ->
	ok.

%% @doc
%% Function: receive_loop/1
%% Purpose: Receives the messages in the list
%%          will be stuck if it do not get the
%%          messages in the list and the test
%%          will time-out
%% Returns: ok 
%% @end
receive_loop([]) ->
	ok;
receive_loop([{Value,StreamId,Threshold,Users}|Rest]) ->
	receive
		{#'basic.deliver'{}, #amqp_msg{payload = Body}} ->
			{Value1,_,StreamId1,Threshold1,Users1} = binary_to_term(Body),
			case {Value1,StreamId1,Threshold1,Users1} == {Value,StreamId,Threshold,Users} of
				true ->
					receive_loop(Rest);
				false ->
					self() ! {#'basic.deliver'{}, #amqp_msg{payload = Body}},
					receive_loop([{Value,StreamId,Threshold,Users}|Rest])
			end
	end.

check_all_exist([],[]) ->
	true;
check_all_exist([],_Reference) ->
	false;
check_all_exist([First|Rest],Reference) ->
	case lists:member(First, Reference) of
		true ->
			check_all_exist(Rest,lists:delete(First, Reference));
		false ->
			false
	end.
	

