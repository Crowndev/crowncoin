#ifndef LEGACYSENDCONFIG_H
#define LEGACYSENDCONFIG_H

#include <QDialog>

namespace Ui {
    class LegacysendConfig;
}
class WalletModel;

/** Multifunctional dialog to ask for passphrases. Used for encryption, unlocking, and changing the passphrase.
 */
class LegacysendConfig : public QDialog
{
    Q_OBJECT

public:

    LegacysendConfig(QWidget *parent = 0);
    ~LegacysendConfig();

    void setModel(WalletModel *model);


private:
    Ui::LegacysendConfig *ui;
    WalletModel *model;
    void configure(bool enabled, int coins, int rounds);

private slots:

    void clickBasic();
    void clickHigh();
    void clickMax();
};

#endif // LEGACYSENDCONFIG_H
