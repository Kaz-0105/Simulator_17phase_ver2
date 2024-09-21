classdef Config < utils.class.Common
    properties
        Vissim;
    end

    properties
        simulator;
        network;
        controllers;
    end

    methods
        function obj = Config()
            % Simulatorクラス用の設定を作成
            obj.create('simulator');

            % VissimのCOMオブジェクトを作成
            obj.create('Vissim');

            % Networkクラス用の設定を作成
            obj.create('network');

            % Controllersクラス用の設定を作成
            obj.create('controllers');
        end
    end

    methods
        create(obj, property_name);
    end
end