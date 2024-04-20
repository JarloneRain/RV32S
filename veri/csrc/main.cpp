#include <bits/stdc++.h>
using namespace std;

int js[4] = {0, 1, 2, 3};
int n;
int nxs()
{
    int ans = 0;
    for (int i = 1; i < n; i++)
    {
        for (int j = 0; j < i;j++){
            ans += js[j] > js[i];
        }
    }
    return ans;
}

int main(){
    cin >> n;
    do
    {
        cout << (nxs() % 2 == 0 ? '+' : '-');
        for (int k = 0; k < n;k++){
            cout << 'm' << k << js[k]<<'*';
        }
        cout << endl;
    } while (next_permutation(js, js + n));

    return 0;
}
