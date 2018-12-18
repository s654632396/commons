    /**
     * 页码计算器, 返回需要生成的页码数组
     * @param current           当前页
     * @param total               总页数
     * @param showPage       仅显示的页数数量
     * @return Array            页码数组
     */
    const pagerCaculator = (current, total, showPage) => {
        // 默认值
        showPage = typeof showPage !== 'undefined' ? Number(showPage) : 10;
        // 显示页数的一半
        const halfShowPage = Number.isInteger(showPage / 2) ? showPage / 2 : Number.parseInt(showPage / 2) + 1;
        // 强制转Number
        current = Number(current)
            , total = Number(total);

        // 如果总页数较少的情况
        if (showPage > total) {
            showPage = total;
        }

        if (Number.isNaN(current)) {
            return [];
        }
        // start 起始页
        let start = 1;
        // 新的起始页
        const needNewStart = current - (halfShowPage - 1);
        if (needNewStart > 1) {
            start = needNewStart;
        }
        // 由起始页计算得到的结束页码
        const end = start + (showPage - 1);
        // 如果结束页码超过总页数，则由结束页来计算起始页（反向计算）
        if (end > total) {
            start = total - (showPage - 1);
        }
        // 生成页码数组
        return new Array(showPage).fill(start).map((el, i) => el + i);
    }
