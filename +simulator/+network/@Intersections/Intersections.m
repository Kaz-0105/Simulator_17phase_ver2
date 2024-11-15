classdef Intersections < utils.class.Container
    properties
        Config;
        Timer;
        Network;
    end

    methods
        function obj = Intersections(Network)
            % ConfigクラスとTimerクラスとNetworkクラスを設定
            obj.Config = Network.get('Config');
            obj.Timer = Network.get('Timer');
            obj.Network = Network;

            % 要素クラスを作成
            obj.create('Elements');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
    end
end