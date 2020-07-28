% varout = vardefault(query_var,default_val)
%%%% if query_var exists and is not empty, leave as is; if does not exist or is empty,
%%%% set to default
% last updated 5/22/18 on thermaltake

function varout = vardefault(query_var,default_val)

if evalin('caller',['exist(''',query_var,''',''var'')'])... % if var exists in caller workspace
    && evalin('caller',['~isempty(',query_var,')']) %%% and is not empty
    varout = evalin('caller',query_var); % use the value that already exists
else % if variable isn't specified in caller yet
    varout = default_val; % set to the default value
end