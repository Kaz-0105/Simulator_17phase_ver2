classdef SignalHead < utils.class.Common
    properties
        Config;
        SignalHeads;
        Link;
        FromLink;
        ToLink;
        FromRoad;
        ToRoad;
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

            % Link関連の設定
            obj.create('Links');

            % Road関連の設定
            obj.create('Roads');
        end
    end

    methods
        create(obj, property_name);
    end
end