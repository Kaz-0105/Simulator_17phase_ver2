classdef SignalHeads < utils.class.Container
    properties
        Config;
    end

    methods
        function obj = SignalHeads(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとNetworkクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.set('Network', UpperClass);

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');

                % GroupHeadMapを作成
                obj.create('GroupHeadsMap');

                % Roadクラスにおいて必要のないSignalHeadsを削除
                obj.get('Network').get('Roads').delete('SignalHeads');

            elseif isa(UpperClass, 'simulator.network.Road')
                % ConfigクラスとRoadクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.set('Road', UpperClass);

            elseif isa(UpperClass, 'simulator.network.SignalGroup')
                % ConfigクラスとSignalGroupクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.set('SignalGroup', UpperClass);

            else
                error('UppeClass is not a valid class');
            end
        end
    end

end