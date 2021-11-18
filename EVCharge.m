% ======================================================
% Meta
% ======================================================
warning('off','fuzzy:general:warnDeprecation_Newfis') 
warning('off','fuzzy:general:warnDeprecation_Addvar')
warning('off','fuzzy:general:warnDeprecation_Addmf')
warning('off','fuzzy:general:warnDeprecation_Evalfis')
clc

% A declaration of new FIS
a = newfis('Control Unit')
%a = newfis('Control Unit', 'DefuzzificationMethod', 'som')

%Default options for FIS
%                                                         AND OR    Impl Agg  Defuzzification
%a=newfis('Control Unit','mamdani','min','max', 'min','max','centroid');

%Different options for FIS
%                                                         AND OR    Impl Agg  Defuzzification
%a=newfis('Control Unit','mamdani','prod','probor', 'prod','max','centroid');

% ======================================================
%                       INPUT
%               Major fault detected
% ======================================================

a = addvar(a, 'input', 'Major Fault Detected', [0, 1]);

% Populating the 1st input variable with membership functions
a = addmf(a, 'input', 1, 'No', 'trapmf', [0 0 0.5 0.5]);
a = addmf(a, 'input', 1, 'Yes', 'trapmf', [0.5 0.5 1 1]);


% ======================================================
%                       INPUT
%                 Max Charger Output
% ======================================================
a = addvar(a, 'input', 'Max Charger Output (kW)', [0, 350]);

% Populating the 1st input variable with membership functions
a = addmf(a, 'input', 2, 'Disconnected', 'trapmf', [0 0 0 0]);
a = addmf(a, 'input', 2, 'Level 1','trapmf',[0 0 2 2.5]); 
a = addmf(a, 'input', 2, 'Level 2', 'trapmf',[2.5 3 19.2 40]); 
a = addmf(a, 'input', 2, 'DC Fast', 'trapmf',[19.2 350 350 350]);



% ======================================================
%                       INPUT
%                    Charge Level (%)
% ======================================================
a = addvar(a, 'input', 'Battery Charge Level', [0, 100]);

% Populating the 1st input variable with membership functions
a = addmf(a, 'input', 3, 'Very Low', 'trapmf', [0 0 5 10]);  % Slow charging
a = addmf(a, 'input', 3, 'Low','trapmf',[9 10 18 20]);        % Fastest charging
a = addmf(a, 'input', 3, 'Medium', 'trapmf',[18 20 75 80]);  % Regular charging
a = addmf(a, 'input', 3, 'High', 'trapmf',[75 80 100 100]);  % Trickle charging



% ======================================================
%                       OUTPUT
%                    Charge Speed
% ======================================================
% Declaring a new variable - this is an OUTPUT(1)
a=addvar(a,'output','Charge Rate (kW)',[0 360]);

% Populating the output variable with membership functions
a = addmf(a, 'output', 1, 'Off', 'trapmf', [0 0 0 0]);
a = addmf(a, 'output', 1, 'Slow','trapmf',[0 0 1.4 2.5]); 
a = addmf(a, 'output', 1, 'Trickle', 'trapmf',[1.9 4 6 50]); 
a = addmf(a, 'output', 1, 'Fast', 'trimf',[6 100 200]); 
a = addmf(a, 'output', 1, 'Super', 'trapmf',[150 360 360 360]);



% ======================================================
%                       RULES
% ======================================================
rule1 = [2 -1 -1 1 1 1]
% [fault, available, charge, output, weight, and]

% Level 1 available
rule3 = [1 2 1 2 1 1]
rule4 = [1 2 2 2 1 1]
rule5 = [1 2 3 2 1 1]
rule6 = [1 2 4 2 1 1]

% Level 2 available
rule7 = [1 3 1 3 1 1]
rule8 = [1 3 2 4 1 1]
rule9 = [1 3 3 4 1 1]
rule10 = [1 3 4 3 1 1]

% DC Fast available
rule11 = [1 4 1 4 1 1]
rule12 = [1 4 2 5 1 1]
rule13 = [1 4 3 4 1 1]
rule14 = [1 4 4 3 1 1]

% A matrix to hold the rule arrays
ruleList = [ 
    rule1;
    rule3;
    rule4;
    rule5;
    rule6;
    rule7;
    rule8;
    rule9;
    rule10;
    rule11;
    rule12;
    rule13;
    rule14;
    ];

% Print the rules to the command window
showrule(a)

% Add the rules to the fis
a = addrule(a, ruleList);

% A varaible to hold the excel file
% data = ('ControlUnitData.xlsx');

% % Read in the values and store the in testData
% testData = xlsread(data);

% % A for loop to process the data and output the results
% for i=1:size(testData,1)
%         output = evalfis([testData(i, 1), testData(i, 2), testData(i, 3) ], a);
%         fprintf('%d) In(1): %.2f, In(2) %.2f, In(3) %.2f => Out: %.2f \n\n',i,testData(i, 1),testData(i, 2),testData(i, 3), output);  
%         xlswrite('ControlUnitData.xlsx', output, 1, sprintf('F%d',i+1));
% end

% The ruleview allows you to see the rule-base
ruleview(a)

% The subplots to visualise the system
figure(1)
subplot(3,1,1), plotmf(a, 'input', 1)
subplot(3,1,2), plotmf(a, 'input', 2)
subplot(3,1,3), plotmf(a, 'input', 3)
subplot(3,1,4), plotmf(a, 'output', 1)
