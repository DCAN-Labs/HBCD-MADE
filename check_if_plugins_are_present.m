function check_if_plugins_are_present(ext)
%CHECK_IF_PLUGINS_ARE_PRESENT helper function to check if all plugins needed
%by MADE are present
if exist('eeglab','file')==0
    error(['Please make sure EEGLAB is on your Matlab path. Please see EEGLAB' ...
        'wiki page for download and instalation instructions']);
end

if strcmp(ext, '.mff')==1
    if exist('mff_import', 'file')==0
        error(['Please make sure "mffmatlabio" plugin is in EEGLAB plugin folder and on Matlab path.' ...
            ' Please see EEGLAB wiki page for download and instalation instructions of plugins.' ...
            ' If you are not analysing EGI .mff data, edit the data import function below.']);
    end
else
    warning('Your data are not EGI .mff files. Make sure you edit data import function before using this script');
end

if exist('pop_firws', 'file')==0
    error(['Please make sure  "firfilt" plugin is in EEGLAB plugin folder and on Matlab path.' ...
        ' Please see EEGLAB wiki page for download and instalation instructions of plugins.']);
end

if exist('channel_properties', 'file')==0
    error(['Please make sure "FASTER" plugin is in EEGLAB plugin folder and on Matlab path.' ...
        ' Please see EEGLAB wiki page for download and instalation instructions of plugins.']);
end

if exist('ADJUST', 'file')==0
    error(['Please make sure you download modified "ADJUST" plugin from GitHub (link is in MADE manuscript)' ...
        ' and ADJUST is in EEGLAB plugin folder and on Matlab path.']);
end



end