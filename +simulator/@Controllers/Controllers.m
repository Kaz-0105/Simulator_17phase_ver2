classdef Controllers < utils.class.Container
    properties
        Config;
        Simulator;

        Field;
    end

    properties
        Elements;
    end

    methods
        function obj = Controllers(Simulator)
            % Configクラスを設定
            obj.Config = Simulator.get('Config');

            % Simulatorクラスを設定
            obj.Simulator = Simulator;

            % Fieldクラスを作成
            obj.Field = obj.Simulator.get('Field');
            obj.Field.set('Controllers', obj);

            % 要素クラスを作成
            obj.create('Elements');
        end
    end

    methods
        create(obj, property_name);
    end
end