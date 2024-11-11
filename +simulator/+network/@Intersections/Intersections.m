classdef Intersections < utils.class.Container
    properties
        Config;
        Network;
        Roads;
    end

    methods
        function obj = Intersections(Network)
            % Configクラスを設定
            obj.Config = Network.get('Config');

            % Networkクラスを設定
            obj.Network = Network;

            % Roadsクラスを作成
            obj.Roads = obj.Network.get('Roads');
            obj.Roads.set('Intersections', obj);

            % 要素クラスを作成
            obj.create('Elements');

            % Intersectionクラスにsignal_controllerを作成
            obj.create('signal_controller');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
    end
end