classdef SignalHead < utils.class.Common
    properties
        Config;
        SignalHeads;
    end

    properties
        id;
        Vissim;
    end

    methods
        function obj = SignalHead(SignalHeads, id)
            % ConfigクラスとSignalHeadsクラスを設定
            obj.Config = SignalHeads.get('Config');
            obj.SignalHeads = SignalHeads;

            % idを設定
            obj.id = id;

            % SignalHeadのCOMオブジェクトを設定
            obj.create('Vissim');
        end
    end

    methods
        create(obj, property_name);
    end
end