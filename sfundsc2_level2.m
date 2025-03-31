function sfundsc2_level2(block)
  %SFUNDSC2_LEVEL2 Level-2 version of sfundsc2.m
  %  
  %   Copyright 2003-2007 The MathWorks, Inc. 
    
  %%
  %% The setup method is used to setup the basic attributes of the
  %% S-function such as ports, parameters, etc. Do not add any other
  %% calls to the main body of the function.  
  %%   
  setup(block);
    
  %endfunction
  
  function setup(block)
  
    % Register number of ports
    block.NumInputPorts  = 1;
    block.NumOutputPorts = 1;
    
    % Setup port properties to be inherited or dynamic
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;
  
    % Override input port properties
    block.InputPort(1).DatatypeID  = 0;  % double
    block.InputPort(1).Complexity  = 'Real';
    block.InputPort(1).Dimensions        = 1;
    block.InputPort(1).DirectFeedthrough = false;
    
    % Override output port properties
    block.OutputPort(1).DatatypeID  = 0; % double
    block.OutputPort(1).Complexity  = 'Real';
    block.OutputPort(1).Dimensions       = 1;
    
    % Register parameters
    block.NumDialogPrms     = 0;
  
    % Register sample times
    block.SampleTimes = [.10 0];
    
    %% -----------------------------------------------------------------
    %% Options
    %% -----------------------------------------------------------------
    % Specify if Accelerator should use TLC or call back into 
    % MATLAB file
    block.SetAccelRunOnTLC(false);
    
      
    %% -----------------------------------------------------------------
    %% Register methods
    %% -----------------------------------------------------------------
    block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Outputs', @Outputs);
    block.RegBlockMethod('Update', @Update);
  %endfunction
  
  %% -------------------------------------------------------------------
  %% The local functions 
  %% -------------------------------------------------------------------
  function DoPostPropSetup(block)
    
    block.NumDworks = 1;
    block.Dwork(1).Name            = 'x0';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;      % double
    block.Dwork(1).Complexity      = 'Real'; % real
    block.Dwork(1).UsedAsDiscState = true;
  
   %endfunction
  
  function InitializeConditions(block)
  %% Initialize Dwork  
    block.Dwork(1).Data = 0;
  
  %endfunction
  
  function Outputs(block)
    
    block.OutputPort(1).Data = block.Dwork(1).Data;
    
  %endfunction
  
  function Update(block)
    
    block.Dwork(1).Data = block.InputPort(1).Data;
    
  %endfunction