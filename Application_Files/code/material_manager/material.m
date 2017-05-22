classdef material < handle
%MATERIAL    QFT class for material data processing.
%   This class contains methods for pre-analysis processing tasks.
%   
%   Functions in MATERIAL are used to replicate the behaviour of the 
%   Material Manager GUI.
%   
%   Quick Fatigue Tool 6.10-08 Copyright Louis Vallance 2017
%   Last modified 15-May-2017 08:49:00 GMT
    
    %%
    
    methods(Static = true)
        %% Start Material Manager
        function [] = manage()
            %MATERIAL.MANAGE    Start the Material Manager GUI.
            %
            %   MATERIAL.MANAGE() is called without arguments.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            MaterialManager
        end
        
        %% List materials in local database
        function [] = list()
            %MATERIAL.LIST    List materials in the local database.
            %   This function lists the materials saved in the local
            %   material databse.
            %
            %   MATERIAL.LIST() is called without arguments.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            
            clc
            localMaterials = dir([pwd, '\Data\material\local\*.mat']);
            
            fprintf('Materials in local database:\n\n')
            
            if isempty(localMaterials) == 1.0
                fprintf('(none)\n')
            else
                for i = 1:length(localMaterials)
                    fprintf('%s\n', localMaterials(i).name(1.0:end - 4.0))
                end
            end
        end
        
        %% Import material into local database from text file
        function [] = import(material)
            %MATERIAL.IMPORT    QFT function to import material text file.
            %   This function imports a material text file into the local
            %   material database.
            %
            %   MATERIAL.IMPORT(MATERIAL) imports material data from a text
            %   file 'MATERIAL.*' containing valid material definitioins.
            %   The file must begin and end with the keywords
            %   *USER MATERIAL and *END MATERIAL, respectively.
            %
            %   Example material text file:
            %       *USER MATERIAL, steel
            %       *MECHANICAL
            %       200e3, , 400, ,
            %       *FATIGUE, constants
            %       930, -0.095, , ,
            %       *REGRESSION, none
            %       *END MATERIAL
            %
            %   See also importMaterial, keywords, job.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5.6 Creating a material from a text file
            %
            %   Reference section in Quick Fatigue Tool User Settings
            %   Reference Guide
            %      3 Material keywords
            
            clc
            setappdata(0, 'materialManagerImport', 1.0)
            
            % Check that the material exists
            if exist(material, 'file') == 0.0
                fprintf('ERROR: Unable to locate material ''%s''\n', material)
                return
            end
            
            [error, material_properties, materialName, ~, ~] = importMaterial.processFile(material, -1.0); %#ok<ASGLU>
            
            if exist(['Data/material/local/', materialName, '.mat'], 'file') == 2.0
                % User is attempting to overwrite an existing material
                response = questdlg(sprintf('The material ''%s'' already exists in the local database. Do you wish to overwrite the material?', materialName), 'Quick Fatigue Tool', 'Overwrite', 'Keep file', 'Cancel', 'Overwrite');
                
                if (strcmpi(response, 'cancel') == 1.0) || (isempty(response) == 1.0)
                    return
                elseif strcmpi(response, 'Keep file') == 1.0
                    % Change the name of the old material
                    oldMaterial = materialName;
                    while exist([oldMaterial, '.mat'], 'file') == 2.0
                        oldMaterial = [oldMaterial , '-old']; %#ok<AGROW>
                    end
                    
                    % Rename the original material
                    movefile(['Data/material/local/', materialName, '.mat'], ['Data/material/local/', oldMaterial, '.mat'])
                end
            end
            
            % Save the material
            try
                save(['Data/material/local/', materialName], 'material_properties')
            catch
                fprintf('ERROR: Unable to save material ''%s''. Make sure the material save location has read/write access\n', materialName)
                return
            end
        end
        
        %% Fetch material from system database
        function [] = fetch()
            %MATERIAL.FETCH    Fetch material from the system database.
            %   This function fetches a copy of a material from the system
            %   databse into the local database, which can then be edited
            %   and used for analysis.
            %
            %   MATERIAL.FETCH() is called without arguments.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            
            clc
            
            quest1 = sprintf('Select a database:\n\n');
            quest2 = sprintf('1: Steel (SAE)\n');
            quest3 = sprintf('2: Steel (BS)\n');
            quest4 = sprintf('3: Steel (ASTM)\n');
            quest5 = sprintf('4: Aluminium\n');
            quest6 = sprintf('5: Iron (ADI)\n');
            quest7 = sprintf('6: Iron (DI)\n');
            quest8 = sprintf('7: Iron (CGI)\n');
            quest9 = sprintf('8: Iron (GI)\n');
            
            databaseToFetch = input([quest1, quest2, quest3, quest4, quest5,...
                quest6, quest7, quest8, quest9]);
            
            % Check validity of user selection
            if isnumeric(databaseToFetch) == 0.0 || (databaseToFetch < 1.0 || databaseToFetch > 8.0 || mod(databaseToFetch, 2.0) ~= 0.0)
                clc
                fprintf('Invalid selection.\n');
                return
            end
            
            quest1 = sprintf('Select a material from the database:\n\n');
            switch databaseToFetch
                case 1.0 % SAE
                    quest2 = sprintf('Select a material from the SAE database:\n\n');
                    quest3 = sprintf('1: SAE-950C\n2: SAE-0030\n3: SAE-0080\n4: SAE-1005\n5: SAE-1006\n');
                    quest4 = sprintf('6: SAE-1006\n7: SAE-1008\n8: SAE-1015\n9: SAE-1020\n10: SAE-1020\n');
                    quest5 = sprintf('11: SAE-1022\n12: SAE-1025\n13: SAE-1025\n14: SAE-1030\n15: SAE-1035\n');
                    quest6 = sprintf('16: SAE-1040\n17: SAE-1045_2\n18: SAE-1045_3\n19: SAE-1045_4\n20: SAE-1045_5\n');
                    quest7 = sprintf('21: SAE-1045_6\n22: SAE-1055\n23: SAE-1080\n24: SAE-1137\n25: SAE-1144\n');
                    quest8 = sprintf('26: SAE-1522\n27: SAE-30302\n28: SAE-30304\n29: SAE-4130\n30: SAE-4140\n');
                    quest9 = sprintf('31: SAE-4142\n32: SAE-4340\n33: SAE-52100\n');
                    quest = [quest1, quest2, quest3, quest4, quest5, quest6, quest7, quest8, quest9];
                    limit = 33.0;
                case 2.0 % BS
                    quest2 = sprintf('Select a material from the BS database:\n\n');
                    quest3 = sprintf('1: BS 1480 G5083\n2: BS 1490 LM13\n3: BS 1490 LM16\n4: BS 1490 LM25\n5: BS 1490\n');
                    quest4 = sprintf('6: BS 1490 LM27\n7: BS 4360 G40B\n8: BS 4360 G43A\n9: BS 4360 G43C\n10: BS 4360 G43D\n');
                    quest5 = sprintf('11: BS 4360 G43D2\n12: BS 970 G040A10\n13: BS 970 G53M40\n14: BS 970 G150M19\n15: BS 4360 G50A\n');
                    quest6 = sprintf('16: BS 970 G225M44\n17: BS 980 G605M36\n18: BS 970 G817M40\n19: BS 970 G835M40\n20: BS 1452 300 4\n');
                    quest7 = sprintf('21: BS 1452 300 6\n22: BS 2789370\n23: BS 2789420\n24: BS 2789420 3\n25: BS 2789600\n');
                    quest8 = sprintf('26: BS 2789700\n27: BS 2789700\n28: BS 1452 5260\n');
                    quest = [quest1, quest2, quest3, quest4, quest5, quest6, quest7, quest8];
                    limit = 28.0;
                case 3.0 % ASTM
                    quest1 = sprintf('Select a material from the ASTM database:\n\n');
                    quest2 = sprintf('1: ASTM A514F\n2: ASTM A579 G71\n3: ASTM A579 G72\n4: ASTM A579 G73\n5: ASTM A715 G50\n');
                    quest3 = sprintf('6: ASTM A715 G80 1\n7: ASTM A715 G80 2\n');
                    quest = [quest1, quest2, quest3];
                    limit = 7.0;
                case 4.0 % Aluminium
                    quest1 = sprintf('Select a material from the aluminium database:\n\n');
                    quest2 = sprintf('1: AL1100 T6\n2: AL2014 T6\n3: AL 2024 T351\n4: AL 2024 T4\n5: AL5456 H311\n');
                    quest3 = sprintf('6: AL7075 T6\n');
                    quest = [quest1, quest2, quest3];
                    limit = 6.0;
                case 5.0 % ADI
                    quest1 = sprintf('Select a material from the ADI database:\n\n');
                    quest2 = sprintf('1: ADI GRD1 AUS 25mm\n2: ADI GRD1 AUS LIT\n3: ADI GRD2 AUS 25mm\n4: ADI GRD2 AUS CONTRB\n5: ADI GRD3 AUS 25mm\n');
                    quest3 = sprintf('6: ADI GRD3 AUS CONTRB\n7: ADI GRD4 AUS 25mm\n8: ADI GRD4 AUS CONTRB');
                    quest = [quest1, quest2, quest3];
                    limit = 8.0;
                case 6.0 % DI
                    quest1 = sprintf('Select a material from the DI database:\n\n');
                    quest2 = sprintf('1: DI 4018 FAN 25mm\n2: DI 4018 SCAN 25mm\n3: DI 4018 AC 25mm\n4: DI 4512 AC 25mm\n5: DI 4512 AC CONTR1\n');
                    quest3 = sprintf('6: DI 4512 AC CONTR2\n7: DI 4512 AC CONTR3\n8: DI 4512 FAN CONTR\n9: DI 5506 AC CONTR1\n10: DI 5506 AC CONTR2');
                    quest4 = sprintf('11: DI 5506 AC CONTR3\n12: DI 5506 AC CONTR4\n13: DI 5506 AC CONTR5\n14: DI 5506 N CONTR\n15: DI 7703 AC 25mm');
                    quest5 = sprintf('16: DI 7703 N 25mm\n17: DI 7703 N 76mm\n18: DI 7703 N CONTR\n19: DI 9002 QT 25mm\n');
                    quest = [quest1, quest2, quest3, quest4, quest5];
                    limit = 19.0;
                case 7.0 % CGI
                    quest1 = sprintf('Select a material from the CGI database:\n\n');
                    quest2 = sprintf('1: CGI 300HN AC 25mm\n2: CGI 350HN AC 25mm\n3: CGI 400HN AC 25mm\n');
                    quest = [quest1, quest2];
                    limit = 3.0;
                case 8.0 % GI
                    quest1 = sprintf('Select a material from the GI database:\n\n');
                    quest2 = sprintf('1: GI 20B AC 25mm\n2: GI 30B AC 13mm\n3: GI 30B AC 25mm\n4: GI 30B AC 76mm\n5: GI 30 AC 25mm CONTR');
                    quest3 = sprintf('6: GI 35B AC 25mm\n7: GI 40B AC 25mm\n8: GI AGI AUS 25mm\n');
                    quest = [quest1, quest2, quest3];
                    limit = 8.0;
                otherwise
            end
            materialToFetch = input(quest);
            
            % Check validity of user selection
            if isnumeric(materialToFetch) == 0.0 || (materialToFetch < 1.0 || materialToFetch > limit || mod(materialToFetch, 2.0) ~= 0.0)
                clc
                fprintf('Invalid selection.\n');
                return
            end
            
            % Check that the system database exists
            if exist('mat.mat', 'file') == 2.0
                load('mat.mat')
            else
                fprintf('Missing file ''mat.mat''. Check that the file exists in Data\\material\\system.\n')
                return
            end
            
            % Get the database
            switch databaseToFetch
                case 1.0
                    % Get the list of materials belonging to this family of metals
                    fields = fieldnames(mat.sae);
                    
                    % Get the material properties
                    materialF = fields(materialToFetch);
                    properties = getfield(mat.sae, char(materialF)); %#ok<*GFLD>
                case 2.0
                    % Get the list of materials belonging to this family of metals
                    fields = fieldnames(mat.bs);
                    
                    % Get the material properties
                    materialF = fields(materialToFetch);
                    properties = getfield(mat.bs, char(materialF));
                case 3.0
                    % Get the list of materials belonging to this family of metals
                    fields = fieldnames(mat.astm);
                    
                    % Get the material properties
                    materialF = fields(materialToFetch);
                    properties = getfield(mat.astm, char(materialF));
                case 4.0
                    % Get the list of materials belonging to this family of metals
                    fields = fieldnames(mat.al);
                    
                    % Get the material properties
                    materialF = fields(materialToFetch);
                    properties = getfield(mat.al, char(materialF));
                case 5.0
                    % Get the list of materials belonging to this family of metals
                    fields = fieldnames(mat.adi);
                    
                    % Get the material properties
                    materialF = fields(materialToFetch);
                    properties = getfield(mat.adi, char(materialF));
                case 6.0
                    % Get the list of materials belonging to this family of metals
                    fields = fieldnames(mat.di);
                    
                    % Get the material properties
                    materialF = fields(materialToFetch);
                    properties = getfield(mat.di, char(materialF));
                case 7.0
                    % Get the list of materials belonging to this family of metals
                    fields = fieldnames(mat.cgi);
                    
                    % Get the material properties
                    materialF = fields(materialToFetch);
                    properties = getfield(mat.cgi, char(materialF));
                case 8.0
                    % Get the list of materials belonging to this family of metals
                    fields = fieldnames(mat.gi);
                    
                    % Get the material properties
                    materialF = fields(materialToFetch);
                    properties = getfield(mat.gi, char(materialF));
                otherwise
            end
            
            % If there was an error while reading the system databse, RETURN
            if isstruct(properties) == 0.0
                if properties == 0.0
                    return
                end
            end
            
            material_properties = struct(...
                'default_algorithm', properties.default_algorithm,...
                'default_msc', properties.default_msc,...
                'class', properties.class,...
                'behavior', properties.behavior,...
                'reg_model', 1.0,...
                'cael', properties.cael,...
                'cael_active', 1.0,...
                'e', properties.e,...
                'e_active', 1.0,...
                'uts', properties.uts,...
                'uts_active', 1.0,...
                'proof', properties.proof,...
                'proof_active', 1.0,...
                'poisson', properties.poisson,...
                'poisson_active', 1.0,...
                's_values', properties.s_values,...
                'n_values', properties.n_values,...
                'r_values', properties.r_values,...
                'sf', properties.sf,...
                'sf_active', 1.0,...
                'b', properties.b,...
                'b_active', 1.0,...
                'ef', properties.ef,...
                'ef_active', 1.0,...
                'c', properties.c,...
                'c_active', 1.0,...
                'kp', properties.kp,...
                'kp_active', 1.0,...
                'np', properties.np,...
                'np_active', 1.0,...
                'nssc', properties.nssc,...
                'nssc_active', 1.0,...
                'comment', properties.comment);
            
            if isempty(properties.cael)
                material_properties.cael_active = 0.0;
            end
            if isempty(properties.e)
                material_properties.e_active = 0.0;
            end
            if isempty(properties.uts)
                material_properties.uts_active = 0.0;
            end
            if isempty(properties.proof)
                material_properties.proof_active = 0.0;
            end
            if isempty(properties.poisson)
                material_properties.poisson_active = 0.0;
            end
            if isempty(properties.sf)
                material_properties.sf_active = 0.0;
            end
            if isempty(properties.b)
                material_properties.b_active = 0.0;
            end
            if isempty(properties.ef)
                material_properties.ef_active = 0.0;
            end
            if isempty(properties.c)
                material_properties.c_active = 0.0;
            end
            if isempty(properties.kp)
                material_properties.kp_active = 0.0;
            end
            if isempty(properties.np)
                material_properties.np_active = 0.0;
            end
            if isempty(properties.nssc)
                material_properties.nssc_active = 0.0;
            end
            if isempty(properties.comment)
                material_properties.comment = '';
            end
            
            if properties.default_algorithm < 4.0
                material_properties.default_algorithm = properties.default_algorithm + 1.0; %#ok<STRNU>
            elseif properties.default_algorithm < 10.0
                material_properties.default_algorithm = properties.default_algorithm + 2.0; %#ok<STRNU>
            else
                material_properties.default_algorithm = properties.default_algorithm + 3.0; %#ok<STRNU>
            end
            
            % Get the material name
            materialName = char(materialF);
            
            % Check if the material already exists
            userMaterials = dir('Data/material/local/*.mat');
            
            for i = 1:length(userMaterials)
                if strcmpi([materialName, '.mat'], userMaterials(i).name) == 1.0
                    fprintf(sprintf('%s already exists in the local database and cannot be overwritten.\n', materialName));
                    return
                end
            end
            
            % Save the copy in the /LOCAL directory
            try
                save(['Data\material\local\', materialName, '.mat'], 'material_properties')
            catch
                fprintf('Cannot fetch ''%s'' because the local database is not currently on the MATLAB path.\n', copiedMaterial);
                return
            end
        end
        
        %% Edit material in local database
        function [] = edit(material)
            %MATERIAL.EDIT    Edit material in the local database.
            %   This function opens the material editor GUI for a selected
            %   material in the local database.
            %
            %   MATERIAL.EDIT(MATERIAL) edits the material MATERIAL.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            
            clc
            if strcmpi(material(end - 3.0:end), '.mat') == 1.0
                material = material(1.0:end - 4.0);
            end
            
            setappdata(0, 'editMaterial', 1.0)
            
            setappdata(0, 'materialToEdit', material)
            UserMaterial
        end
        
        %% Rename material in local database
        function [] = rename(oldName, newName)
            %MATERIAL.RENAME    Rename material in the local database.
            %   This function renames a material in the local database.
            %
            %   MATERIAL.RENAME(OLDNAME, NEWNAME) renames the material
            %   OLDNAME to the material NEWNAME.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            
            clc
            if isempty(newName) == 1.0
                return
            elseif isempty(regexp(newName, '[/\\*:?"<>|]', 'once')) == 0.0
                fprintf('The material name cannot contain any of the following characters: / \\ * : ? " < > |\n');
                return
            elseif strcmp(newName, oldName) == 1.0
                % Material already exists
                if exist([newName, '.mat'], 'file') == 0.0
                    fprintf('Could not rename %s because it no longer exists in the local database.\n', oldName);
                else
                    fprintf('%s already exists in the local database and cannot be overwritten.\n', newName);
                end
                return
            else
                % Create paths to old and new material names
                fullpathOld = [pwd, '\Data\material\local\', oldName, '.mat'];
                fullpathNew = [pwd, '\Data\material\local\', newName, '.mat'];
                
                % Rename the material
                try
                    movefile(fullpathOld, fullpathNew)
                catch
                    if exist(fullpathOld, 'file') == 0.0
                        fprintf('Could not rename %s because it does not exist in the local database.\n', newName);
                    else
                        fprintf('Material name %s is invalid.\n', newName);
                    end
                    return
                end
            end
        end
        
        %% Delete material from local database
        function [] = remove(material)
            %MATERIAL.REMOVE    Remove material in the local database.
            %   This function removes a material in the local database.
            %
            %   MATERIAL.REMOVE(MATERIAL) removes the material MATERIAL
            %   from the local database.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            
            clc
            
            if strcmpi(material(end - 3.0:end), '.mat') == 1.0
                material = material(1.0:end - 4.0);
            end
            
            fullpath = [pwd, '\Data\material\local\', material, '.mat'];
            if exist(fullpath, 'file') ~= 0.0
                delete(fullpath);
            else
                fprintf('Could not delete %s because it does not exist in the local database.\n', material);
            end
        end
        
        %% Evaluate material in local database
        function [] = evaluate(material)
            %MATERIAL.EVALUATE    Evaluate material in the local database.
            %   This function evaluates a material in the local database.
            %
            %   MATERIAL.EVALUATE(MATERIAL) evaluates the material MATERIAL
            %   in the local database.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            
            clc
            
            % Flag to prevent messages from being written
            setappdata(0, 'evaluateMaterialMessenger', 1.0)
            
            % Read material properties
            error = preProcess.getMaterial(material, 0.0, 1.0);
            
            % Remove flag
            rmappdata(0, 'evaluateMaterialMessenger')
            
            % Remove '.mat' extension
            material(end - 3.0:end) = [];
            
            % Create file name
            fileName = sprintf('Project/output/material_reports/%s_report.dat', material);
            
            % Write material evaluation results to file
            evaluateMaterial(fileName, material, error)
            
            if (error > 0.0)
                return
            end
            
            % User message
            message = sprintf('A material report has been written to %s.', fileName);
            
            if (ispc == 1.0) && (ismac == 0.0)
                userResponse = questdlg(message, 'Quick Fatigue Tool', 'Open in MATLAB...',...
                    'Open in Windows...', 'Dismiss', 'Open in MATLAB...');
            elseif (ispc == 0.0) && (ismac == 1.0)
                userResponse = questdlg(message, 'Quick Fatigue Tool', 'Open in MATLAB...',...
                    'Dismiss', 'Open in MATLAB...');
            else
                userResponse = -1.0;
            end
            
            if strcmpi(userResponse, 'Open in MATLAB...')
                addpath('Project/output/material_reports')
                open(fileName)
            elseif strcmpi(userResponse, 'Open in Windows...')
                winopen(fileName)
            end
        end
        
        %% Copy material in local database
        function [] = copy(oldName, newName)
            %MATERIAL.COPY    Copy material in the local database.
            %   This function copies a material in the local database.
            %
            %   MATERIAL.COPY(OLDNAME, NEWNAME) copies the material OLDNAME
            %   to the material NEWNAME.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            
            clc
            
            if strcmpi(oldName(end - 3.0:end), '.mat') == 1.0
                oldName = oldName(1.0:end - 4.0);
            end
            
            if strcmpi(newName(end - 3.0:end), '.mat') == 1.0
                newName = newName(1.0:end - 4.0);
            end
            
            % Check that the material name is valid
            if isempty(newName) == 1.0
                return
            elseif isempty(regexp(newName, '[/\\*:?"<>|]', 'once')) == 0.0
                fprintf('The material name cannot contain any of the following characters: / \\ * : ? " < > |\n');
                return
            else
                % Check if the material already exists
                userMaterials = dir('Data/material/local/*.mat');
                
                for i = 1:length(userMaterials)
                    if strcmp([newName, '.mat'], userMaterials(i).name) == 1.0
                        fprintf('%s already exists in the local database and cannot be overwritten.\n', newName);
                        return
                    end
                end
            end
            
            % Save the new material
            oldPath = ['Data\material\local\', oldName, '.mat'];
            newPath = ['Data\material\local\', newName, '.mat'];
            
            try
                copyfile(oldPath, newPath)
            catch
                if exist(oldName, 'file') == 0.0
                    fprintf('Could not copy %s because it does not exist in the local database.\n', oldName);
                else
                    fprintf('Could not copy %s. Make sure the material name does not contain any illegal characters.\n', newName);
                end
                return
            end
        end
        
        %% Query material in the local database
        function [] = query(material)
            %MATERIAL.QUERY    Query material in the local database.
            %   This function queries a material in the local database.
            %
            %   MATERIAL.QUERY(MATERIAL) queries the material MATERIAL.
            %
            %   Reference section in Quick Fatigue Tool User Guide
            %      5 Materials
            
            clc
            
            if strcmpi(material(end - 3.0:end), '.mat') == 1.0
                material = material(1.0:end - 4.0);
            end
            
            % Get the material properties
            fullpath = ['Data\material\local\', material, '.mat'];
            if exist(fullpath, 'file') == 0.0
                fprintf('Could not query ''%s'' because the file does not exist in the local database.\n', material);
                return
            else
                load(fullpath)
            end
            
            if exist('material_properties', 'var') == 0.0
                fprintf('Error whilst reading ''%s''. Properties are inaccessible.\n', material);
            elseif isempty(material_properties.comment) == 1.0
                fprintf('No information available for %s.\n', material);
            else
                fprintf('Information for material ''%s'': %s\n', material, material_properties.comment);
            end
        end
    end
end