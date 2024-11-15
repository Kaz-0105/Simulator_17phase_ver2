classdef Links < utils.class.Container
    properties
        Config;
        Timer;
    end

    properties
        Vissim;
    end

    methods
        function obj = Links(UpperClass)
            % UpperClassで分岐
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとTimerクラスとNetworkクラスを取得
                obj.Config = UpperClass.get('Config');
                obj.Timer = UpperClass.get('Timer');
                obj.set('Network', UpperClass);

                % VissimのComオブジェクトを取得
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');

                % 接続関係を作成
                obj.create('Connections');

            elseif isa(UpperClass, 'simulator.network.Link')
                % ConfigクラスとTimerクラスとLinkクラスを取得
                obj.Config = UpperClass.get('Config');
                obj.Timer = UpperClass.get('Timer');
                obj.set('Link', UpperClass);
            
            elseif isa(UpperClass, 'simulator.network.Road')
                % ConfigクラスとTimerクラスとRoadクラスを取得
                obj.Config = UpperClass.get('Config');
                obj.Timer = UpperClass.get('Timer');
                obj.set('Road', UpperClass);
                
            else
                error('UpperClass is invalid.');
            end
        end
    end

    methods
        create(obj, property_name);
    end

end