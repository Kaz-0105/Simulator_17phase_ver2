clear;
close all;

% Configクラスを初期化
config = Config();

% Simulatorクラスの初期化
simulator = Simulator(config);

% Simulatorクラスを実行
simulator.run();