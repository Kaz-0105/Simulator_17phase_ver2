classdef Links < utils.class.Container
    properties
        Config;
    end

    properties
        Vissim;
    end

    methods
        function obj = Links(UpperClass)
            % UpperClassで分岐
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとNetworkクラスを取得
                obj.Config = UpperClass.get('Config');
                obj.set('Network', UpperClass);

                % VissimのComオブジェクトを取得
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');

                % 接続関係を作成
                obj.create('Connections');

            elseif isa(UpperClass, 'simulator.network.Link')
                % ConfigクラスとLinksクラスを取得
                obj.Config = UpperClass.get('Config');
                obj.set('Link', UpperClass);
            else
                error('UpperClass is invalid.');
            end
        end
    end

    methods
        create(obj, property_name);
    end

end