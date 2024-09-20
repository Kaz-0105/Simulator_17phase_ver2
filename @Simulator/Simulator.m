classdef Simulator < utils.class.Common
    properties
        Config;
        Field;
    end

    properties
        Vissim;
    end

    methods
        function obj = Simulator(Config)
            % Configクラスを設定
            obj.Config = Config;

            % Vissimと接続（COMオブジェクトの取得（Vissim））
            obj.create('Vissim');

            % Fieldクラスを作成
            obj.Field = simulator.Field(obj);
        end
    end

    methods
        create(obj, property_name);
    end
end