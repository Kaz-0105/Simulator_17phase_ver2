classdef VehicleRoutingDecisions < utils.class.Container
    properties
        Config;
        Network;
    end

    properties
        Vissim;
        Elements;
    end

    methods
        function obj = VehicleRoutingDecisions(Network)
            % ConfigクラスとNetworkクラスを設定
            obj.Config = Network.get('Config');
            obj.Network = Network;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % 下位クラスを作成
            obj.create('Elements');

            % Roadクラスをセット
            obj.create('Road');
        end
    end

    methods
        create(obj, property_name);
    end

end