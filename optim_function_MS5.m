function output_data = optim(input_data)
%%%%%%%%%%%%%%% Manipulates input variable %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
%Transposes the variable
size_input = size(input_data);
if size_input(1) == 1
    input_data = transpose(input_data);
else
end

input_data = input_data.*100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Define the paths and name of the project
root = 'C:\Users\pascu\Dropbox\Pascual\UPV PhD\6. Pasantia TUD\Swmm models dresden';
%root = 'C:\Users\Jörg Seegert\Dropbox\Pascual\UPV PhD\6. Pasantia TUD\Swmm models dresden';


model_name = 'ms5';

base_scenario_info = strcat(root, '\Input Information\Base Scenario');

SUDS_info = strcat(root, '\Input Information\SUDS_Scenario');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Define the SUDS design parameters

%Loads the Excel spreatsheet with SUDS Design Parameters
cd (SUDS_info)
%SUDS_param=importdata("/Design Parameters SUDS.xlsx");
load("Suds_Parameters.mat");

%Load the .inp model as an array
d=mepa_read_inp(strcat(model_name, '_BASE_SUDS.inp'));

%Asigna parámetros a Celda de Bioretención (BC)
d.LID_CONTROLS(2,3)= cellstr(num2str(SUDS_param.data(1,1)));
d.LID_CONTROLS(2,4)= cellstr(num2str(SUDS_param.data(2,1)));
d.LID_CONTROLS(3,3)= cellstr(num2str(SUDS_param.data(5,1)));
d.LID_CONTROLS(5,4)= cellstr(num2str(SUDS_param.data(10,1)));

%Asigna parámetros a Techo Verde (GR)
d.LID_CONTROLS(7,3)= cellstr(num2str(SUDS_param.data(1,2)));
d.LID_CONTROLS(7,4)= cellstr(num2str(SUDS_param.data(2,2)));
d.LID_CONTROLS(8,3)= cellstr(num2str(SUDS_param.data(5,2)));
d.LID_CONTROLS(9,3)= cellstr(num2str(SUDS_param.data(14,2)));

%Asigna parámetros a jardín de Lluvia (RG)
d.LID_CONTROLS(11,3)= cellstr(num2str(SUDS_param.data(1,3)));
d.LID_CONTROLS(11,4)= cellstr(num2str(SUDS_param.data(2,3)));
d.LID_CONTROLS(12,3)= cellstr(num2str(SUDS_param.data(5,3)));

%Asigna parámetros a Trinchera de Infiltración (IT)
d.LID_CONTROLS(15,3)= cellstr(num2str(SUDS_param.data(1,4)));
d.LID_CONTROLS(15,4)= cellstr(num2str(SUDS_param.data(2,4)));
d.LID_CONTROLS(16,3)= cellstr(num2str(SUDS_param.data(7,4)));
d.LID_CONTROLS(17,5)= cellstr(num2str(SUDS_param.data(10,4)));

%Asigna parámetros a Pavimentos Permeables (PP)
d.LID_CONTROLS(19,3)= cellstr(num2str(SUDS_param.data(1,5)));
d.LID_CONTROLS(19,4)= cellstr(num2str(SUDS_param.data(2,5)));
d.LID_CONTROLS(21,3)= cellstr(num2str(SUDS_param.data(5,5)));
d.LID_CONTROLS(22,3)= cellstr(num2str(SUDS_param.data(7,5)));
d.LID_CONTROLS(23,5)= cellstr(num2str(SUDS_param.data(10,5)));
d.LID_CONTROLS(20,3)= cellstr(num2str(SUDS_param.data(12,5)));

%Asigna parámetros a Barril de Lluvia (RB)
d.LID_CONTROLS(25,3)= cellstr(num2str(SUDS_param.data(7,6)));
d.LID_CONTROLS(26,5)= cellstr(num2str(SUDS_param.data(10,6)));

%Asigna parámetros a Swale Vegetado (VS)
d.LID_CONTROLS(28,3)= cellstr(num2str(SUDS_param.data(1,7)));
d.LID_CONTROLS(28,4)= cellstr(num2str(SUDS_param.data(2,7)));
d.LID_CONTROLS(28,7)= cellstr(num2str(SUDS_param.data(3,7)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Define SUDS Distribution
%Define the number of subcatchments, as it will define the number of input
%variables to the optimization problem
num_subcat = length(d.SUBCATCHMENTS);


%%%%%%%% Type of land use %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sand_gravel = startsWith(d.SUBCATCHMENTS(:,1),'Sand');
Stone_Paver = startsWith(d.SUBCATCHMENTS(:,1),'Stone');
Vegetation = startsWith(d.SUBCATCHMENTS(:,1),'Vegetation');
Roof = startsWith(d.SUBCATCHMENTS(:,1),'Roof');
Street = startsWith(d.SUBCATCHMENTS(:,1),'Street');

num_Sand_gravel = sum(Sand_gravel);
num_Stone_Paver = sum(Stone_Paver);
num_Vegetation = sum(Vegetation);
num_Roof= sum(Roof);
num_Street = sum(Street);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Define Relevant variables from the input variable %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define an input equal to the percentage of area in each subcatchment
%assigned to each typology. 
cont_input=1;

p_SG = input_data(cont_input:num_Sand_gravel);
cont_input=cont_input+num_Sand_gravel;

p_SP = input_data(cont_input:(cont_input+num_Stone_Paver));
cont_input=cont_input+num_Stone_Paver;

p_VEG = input_data(cont_input:(cont_input+num_Vegetation));
cont_input=cont_input+num_Vegetation;

p_RO = input_data(cont_input:(cont_input+num_Roof));
cont_input=cont_input+num_Roof;

p_ST = input_data(cont_input:end);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% SAND GRAVEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the distribution of SUDS for the Sand Gravel Subcatchments

%Define the Subcactments that have Sand Gravel
indexes_SG=[];
cont=1;
for i =1:length(Sand_gravel)
    if Sand_gravel(i)==1
        indexes_SG(cont)=i;
        cont=cont+1;
    else
    end
end

%Define a list of the posible SUDS to be assigned in the sand gravel
%order={'BC', 'GR', 'RG', 'IT', 'PP', 'RB', 'VS'};
typo_SG = {'IT'};
num_tip_SG = length(typo_SG);


%Calculates de area in m2 of each SUDS to be assigned
for i = 1:num_Sand_gravel
    for j=1:num_tip_SG
        a_SG(i,j) = ((p_SG(i,j)/100) * str2double(string(d.SUBCATCHMENTS(indexes_SG(i),4))))*10000;
    end
end


%Assigns the LID_USAGE features
num_variables_bu = num_tip_SG*num_Sand_gravel;
cont_subc=1;

for i =1:num_tip_SG
    con_nom_sub=1;
    for j= 1:num_Sand_gravel
        d.LID_USAGE(cont_subc,1) = d.SUBCATCHMENTS(indexes_SG(j),1);

        d.LID_USAGE(cont_subc, 2) = typo_SG(i);

        d.LID_USAGE(cont_subc, 3) = cellstr(num2str(1));
        
        d.LID_USAGE(cont_subc, 4) = cellstr(num2str(a_SG(j,i)));

        d.LID_USAGE(cont_subc, 5) = cellstr(num2str(str2double(string(d.SUBCATCHMENTS(indexes_SG(j),6)))));

        d.LID_USAGE(cont_subc, 6) = cellstr(num2str(0));

        d.LID_USAGE(cont_subc, 7) = cellstr(num2str(100/num_tip_SG));

        d.LID_USAGE(cont_subc, 8) = cellstr(num2str(0));

        cont_subc = cont_subc+1;
        con_nom_sub = con_nom_sub+1;
    end
end

cont_lud_usage=length(d.LID_USAGE)+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Stone Paver %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the distribution of SUDS for the Stone Paver Subcatchments

%Define the Subcactments that have San Gravel
indexes_SP=[];
cont=1;
for i =1:length(Stone_Paver)
    if Stone_Paver(i)==1
        indexes_SP(cont)=i;
        cont=cont+1;
    else
    end
end

%Define a list of the posible SUDS to be assigned in the stone paver
%order={'BC', 'GR', 'RG', 'IT', 'PP', 'RB', 'VS'};
typo_SP = {'PP'};
num_tip_SP = length(typo_SP);


%Calculates de area in m2 of each SUDS to be assigned
for i = 1:num_Stone_Paver
    for j=1:num_tip_SP
        a_SP(i,j) = ((p_SP(i,j)/100) * str2double(string(d.SUBCATCHMENTS(indexes_SP(i),4))))*10000;
    end
end


%Assigns the LID_USAGE features
num_variables_bu = num_tip_SP*num_Stone_Paver;
cont_subc=cont_lud_usage;

for i =1:num_tip_SP
    con_nom_sub=1;
    for j= 1:num_Stone_Paver
        d.LID_USAGE(cont_subc,1) = d.SUBCATCHMENTS(indexes_SP(j),1);

        d.LID_USAGE(cont_subc, 2) = typo_SP(i);

        d.LID_USAGE(cont_subc, 3) = cellstr(num2str(1));
        
        d.LID_USAGE(cont_subc, 4) = cellstr(num2str(a_SP(j,i)));

        d.LID_USAGE(cont_subc, 5) = cellstr(num2str(str2double(string(d.SUBCATCHMENTS(indexes_SP(j),6)))));

        d.LID_USAGE(cont_subc, 6) = cellstr(num2str(0));

        d.LID_USAGE(cont_subc, 7) = cellstr(num2str(100/num_tip_SP));

        d.LID_USAGE(cont_subc, 8) = cellstr(num2str(0));

        cont_subc = cont_subc+1;
        con_nom_sub = con_nom_sub+1;
    end
end

cont_lud_usage=length(d.LID_USAGE)+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Vegetation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the distribution of SUDS for the Vegetation Subcatchments

%Define the Subcactments that have Vegetation
indexes_VEG=[];
cont=1;
for i =1:length(Vegetation)
    if Vegetation(i)==1
        indexes_VEG(cont)=i;
        cont=cont+1;
    else
    end
end

%Define a list of the posible SUDS to be assigned in the stone paver
%order={'BC', 'GR', 'RG', 'IT', 'PP', 'RB', 'VS'};
typo_VEG = {'RG'};
num_tip_VEG = length(typo_VEG);


%Calculates de area in m2 of each SUDS to be assigned
for i = 1:num_Vegetation
    for j=1:num_tip_VEG
        a_VEG(i,j) = ((p_VEG(i,j)/100) * str2double(string(d.SUBCATCHMENTS(indexes_VEG(i),4))))*10000;
    end
end


%Assigns the LID_USAGE features
num_variables_bu = num_tip_VEG*num_Vegetation;
cont_subc=cont_lud_usage;

for i =1:num_tip_VEG
    con_nom_sub=1;
    for j= 1:num_Vegetation
        d.LID_USAGE(cont_subc,1) = d.SUBCATCHMENTS(indexes_VEG(j),1);

        d.LID_USAGE(cont_subc, 2) = typo_VEG(i);

        d.LID_USAGE(cont_subc, 3) = cellstr(num2str(1));
        
        d.LID_USAGE(cont_subc, 4) = cellstr(num2str(a_VEG(j,i)));

        d.LID_USAGE(cont_subc, 5) = cellstr(num2str(str2double(string(d.SUBCATCHMENTS(indexes_VEG(j),6)))));

        d.LID_USAGE(cont_subc, 6) = cellstr(num2str(0));

        d.LID_USAGE(cont_subc, 7) = cellstr(num2str(100/num_tip_VEG));

        d.LID_USAGE(cont_subc, 8) = cellstr(num2str(0));

        cont_subc = cont_subc+1;
        con_nom_sub = con_nom_sub+1;
    end
end

cont_lud_usage=length(d.LID_USAGE)+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Roof %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the distribution of SUDS for the Roof Subcatchments

%Define the Subcactments that have Roof
indexes_RO=[];
cont=1;
for i =1:length(Roof)
    if Roof(i)==1
        indexes_RO(cont)=i;
        cont=cont+1;
    else
    end
end

%Define a list of the posible SUDS to be assigned in the stone paver
%order={'BC', 'GR', 'RG', 'IT', 'PP', 'RB', 'VS'};
typo_RO = {'GR'};
num_tip_RO = length(typo_RO);

%Calculates de area in m2 of each SUDS to be assigned
for i = 1:num_Roof
    for j=1:num_tip_RO
        a_RO(i,j) = ((p_RO(i,j)/100) * str2double(string(d.SUBCATCHMENTS(indexes_RO(i),4))))*10000;
    end
end


%Assigns the LID_USAGE features
num_variables_bu = num_tip_RO*num_Roof;
cont_subc=cont_lud_usage;

for i =1:num_tip_RO
    con_nom_sub=1;
    for j= 1:num_Roof
        d.LID_USAGE(cont_subc,1) = d.SUBCATCHMENTS(indexes_RO(j),1);

        d.LID_USAGE(cont_subc, 2) = typo_RO(i);

        d.LID_USAGE(cont_subc, 3) = cellstr(num2str(1));
        
        d.LID_USAGE(cont_subc, 4) = cellstr(num2str(a_RO(j,i)));

        d.LID_USAGE(cont_subc, 5) = cellstr(num2str(str2double(string(d.SUBCATCHMENTS(indexes_RO(j),6)))));

        d.LID_USAGE(cont_subc, 6) = cellstr(num2str(0));

        d.LID_USAGE(cont_subc, 7) = cellstr(num2str(100/num_tip_RO));

        d.LID_USAGE(cont_subc, 8) = cellstr(num2str(0));

        cont_subc = cont_subc+1;
        con_nom_sub = con_nom_sub+1;
    end
end

cont_lud_usage=length(d.LID_USAGE)+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Street %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define the distribution of SUDS for the Street Subcatchments

%Define the Subcactments that have Street
indexes_ST=[];
cont=1;
for i =1:length(Street)
    if Street(i)==1
        indexes_ST(cont)=i;
        cont=cont+1;
    else
    end
end

%Define a list of the posible SUDS to be assigned in the stone paver
%order={'BC', 'GR', 'RG', 'IT', 'PP', 'RB', 'VS'};
typo_ST = {'PP'};
num_tip_ST = length(typo_ST);

%Calculates de area in m2 of each SUDS to be assigned
for i = 1:num_Street
    for j=1:num_tip_ST
        a_ST(i,j) = ((p_ST(i,j)/100) * str2double(string(d.SUBCATCHMENTS(indexes_ST(i),4))))*10000;
    end
end


%Assigns the LID_USAGE features
num_variables_bu = num_tip_ST*num_Street;
cont_subc=cont_lud_usage;

for i =1:num_tip_ST
    con_nom_sub=1;
    for j= 1:num_Street
        d.LID_USAGE(cont_subc,1) = d.SUBCATCHMENTS(indexes_ST(j),1);

        d.LID_USAGE(cont_subc, 2) = typo_ST(i);

        d.LID_USAGE(cont_subc, 3) = cellstr(num2str(1));
        
        d.LID_USAGE(cont_subc, 4) = cellstr(num2str(a_ST(j,i)));

        d.LID_USAGE(cont_subc, 5) = cellstr(num2str(str2double(string(d.SUBCATCHMENTS(indexes_ST(j),6)))));

        d.LID_USAGE(cont_subc, 6) = cellstr(num2str(0));

        d.LID_USAGE(cont_subc, 7) = cellstr(num2str(100/num_tip_ST));

        d.LID_USAGE(cont_subc, 8) = cellstr(num2str(0));

        cont_subc = cont_subc+1;
        con_nom_sub = con_nom_sub+1;
    end
end


%%%%%%%%%%%%%%%%%%%%% Print the Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Prints the .inp file with the SUDS distribution assigned
cd(SUDS_info)
model_SUDS_name =strcat(model_name, '_SUDS.inp');
mepa_write_inp(model_SUDS_name, d);
cd(root)

%%%%%%%%%%%%%%%%%%%%%%%%%%%Run the SUDS scenario an extract information

%Calls the Python Script to run and extract results for SUDS Scenario
cd(SUDS_info)
system ('python SUDS_Scenario_Analysis.py');
csv_file_name_SUDS = strcat('Node_flooding_', model_name, '_SUDS.csv');
node_flooding_SUDS = importdata(csv_file_name_SUDS);
total_flooded_volume_SUDS = sum(node_flooding_SUDS.data(:,3));
cd(root)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calculate Cost of the Solution
cd(SUDS_info)
%unitary_costs = importdata("Unitary Costs.xlsx");
%unitary_costs = readtable("Unitary Costs.xlsx");
unitary_costs_num=csvread('Unitary Costs.csv');
cd(root)

%Auxiliar variables
bc=0;
gr=0;
rg=0;
it=0;
pp=0;
rb=0;
vs=0;

%Identify and summ up the areas used from each typology
size_suds=size(d.LID_USAGE);
for i= 1:size_suds(1)
    if strcmpi(d.LID_USAGE(i,2), 'BC') == 1
        bc=bc + str2num(cell2mat(d.LID_USAGE(i,4)));
    elseif strcmpi(d.LID_USAGE(i,2), 'GR') == 1
        gr=gr + str2num(cell2mat(d.LID_USAGE(i,4)));
    elseif strcmpi(d.LID_USAGE(i,2), 'RG') == 1
        rg=rg + str2num(cell2mat(d.LID_USAGE(i,4)));
    %Unitary cost in m3. Multiply by the width of the structure
    elseif strcmpi(d.LID_USAGE(i,2), 'IT') == 1
        it=it + str2num(cell2mat(d.LID_USAGE(i,4))) * str2num(cell2mat(d.LID_USAGE(i,5)));
    elseif strcmpi(d.LID_USAGE(i,2), 'PP') == 1
        pp=pp + str2num(cell2mat(d.LID_USAGE(i,4)));
    elseif strcmpi(d.LID_USAGE(i,2), 'RB') == 1
        %Unitary cost in m3. Multiply by the width of the structure
        rb=rb + str2num(cell2mat(d.LID_USAGE(i,4))) * str2num(cell2mat(d.LID_USAGE(i,5)));
    elseif strcmpi(d.LID_USAGE(i,2), 'VS') == 1
        vs=vs + str2num(cell2mat(d.LID_USAGE(i,4)));
    else
    end
end

Areas = [bc; gr; rg; it; pp; rb; vs];


%Capital cost
capital_cost=Areas .* unitary_costs_num(:,1);
%Calcula el costo de mantenimiento y operación
costo_manten_anual= capital_cost .* (unitary_costs_num(:,2)/100);
%calcula el Valor Presente Neto para 30 años de vida útil con 3% de tasa de
%descuento
costo_manten_proy = pvfix(0.03, 30, costo_manten_anual);
%Suma los costos totales
costo_total = sum(capital_cost) + sum(costo_manten_proy);

%Calcula el Costo óptimo como millones de euros
costo_optim = costo_total/1000000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function Output and Input
% % % input_data = [p_bu; p_pp];
% % % input_data = p_bu./100;

output_data = [total_flooded_volume_SUDS costo_optim];
toc
end