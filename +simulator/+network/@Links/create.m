function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VissimのComオブジェクトを取得
        obj.Vissim = Net.Links;

    elseif strcmp(property_name, 'Elements')
        % Linkを走査
        for link_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % Linkクラスを作成
            Link = simulator.network.Link(obj, link_id);

            % Linkクラスを追加
            obj.add(Link);
        end
    
    elseif strcmp(property_name, 'Connections')
        % Linkを走査
        for link_id = obj.getKeys()
            % Linkクラスを取得
            Link = obj.itemByKey(link_id);

            % Linkの接続関係を考える
            Link.create('type');

            % Linkのtypeがlinkの場合
            if strcmp(Link.get('type'), 'link')
                % コンテナを作成
                Link.create('Links');
            end
        end

        % Linkを走査
        for link_id = obj.getKeys()
            % Linkクラスを取得
            Link = obj.itemByKey(link_id);

            % Linkのtypeがconnectorの場合
            if strcmp(Link.get('type'), 'connector')
                % ToLinkとFromLinkのIDを取得
                to_link_id = Link.get('Vissim').ToLink.get('AttValue', 'No');
                from_link_id = Link.get('Vissim').FromLink.get('AttValue', 'No');

                % ToLinkクラスとFromLinkクラスを取得
                ToLink = obj.itemByKey(to_link_id);
                FromLink = obj.itemByKey(from_link_id);

                % ToLinkクラスとFromLinkクラスを取得
                Link.set('ToLink', ToLink);
                Link.set('FromLink', FromLink);

                % ToLinkクラスとFromLinkクラスにLinkクラスを追加
                ToLink.get('FromLinks').add(Link, ToLink.get('FromLinks').count() + 1);
                FromLink.get('ToLinks').add(Link, FromLink.get('ToLinks').count() + 1);
            end
        end
    else
        error('Property name is invalid.');
    end
end