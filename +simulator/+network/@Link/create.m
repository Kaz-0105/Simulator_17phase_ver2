function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % LinksクラスのComオブジェクトを取得
        Links = obj.Links.get('Vissim');

        % VissimのComオブジェクトを取得
        obj.Vissim = Links.ItemByKey(obj.id);
    elseif strcmp(property_name, 'class')
        % ToLinkを取得
        ToLink = obj.Vissim.ToLink;

        % ToLinkの有無によって分岐
        if isempty(ToLink)
            % classを設定
            obj.class = 'link';
        else
            % classを設定
            obj.class = 'connector';

            % to_pos, from_posを設定
            obj.set('to_pos', obj.Vissim.get('AttValue', 'ToPos'));
            obj.set('from_pos', obj.Vissim.get('AttValue', 'FromPos'));
        end
    elseif strcmp(property_name, 'Links')
        % ToLinksとFromLinksを初期化
        obj.set('ToLinks', simulator.network.Links(obj));
        obj.set('FromLinks', simulator.network.Links(obj));

    else
        error('Property name is invalid.');
    end
end